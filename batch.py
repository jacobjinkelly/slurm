#!/usr/bin/python3

import argparse
import json
import os
import shutil
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from itertools import product

assert sys.version_info.major == 3
assert sys.version_info.minor >= 6


def get_args():
    parser = argparse.ArgumentParser("Launch a sweep of jobs")

    # arguments that need to be set for each sweep
    parser.add_argument("-p", "--partition", type=str, required=True)
    parser.add_argument("-j", "--j_name", type=str, required=True)
    parser.add_argument("-f", "--file", type=str, required=True)
    parser.add_argument("-q", "--q", type=str, required=True)
    parser.add_argument("-c", "--config", type=str, required=True)

    # default arguments that will rarely be changed
    parser.add_argument("--exp_dir", type=str, default="experiments")
    parser.add_argument("--resource", type=int, default=1)
    parser.add_argument("--cpus_per_task", type=int, default=2)
    parser.add_argument("--mem", type=int, default=16)
    parser.add_argument("--exclude", type=str, default=None)
    parser.add_argument("--ntasks_per_node", type=int, default=1)
    parser.add_argument("--nodes", type=int, default=1)

    return parser.parse_args()


def run_cmd(cmd, pipe, shell=True, check=True, capture_output=True, **kwargs):
    with open(pipe, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=f, shell=shell, check=check, capture_output=capture_output, **kwargs)


def setup(args):
    # create the directory for the sweep
    exp_dir = os.path.join(args.exp_dir, datetime.now().strftime("%F-%H-%M-%S"))
    os.makedirs(exp_dir)

    # copy files for checking sweeps
    shutil.copy("check.sh", exp_dir)
    shutil.copy("param_check.sh", exp_dir)

    # record git state
    run_cmd("git rev-parse HEAD", os.path.join(exp_dir, "commit.state"))
    run_cmd("git diff", os.path.join(exp_dir, "diff.patch"))

    return exp_dir


def parse_config(config_file):
    """
    Parse configuration file for fixed and sweep job hyperparamters.
    """
    with open(config_file, "r") as f:
        config = json.load(f)

    # for fixed args, we just need to return a string for argparse to parse later on
    # for variable args, we need to return an iterator which tries all the possibilities
    # the output of the iterator also needs to be structured so that we know the argument names and values
    # that way we can put the argument names in the job name

    fixed_args = ""
    sweep_args = []
    sweep_keys = []
    for arg_name, args in config.items():
        if isinstance(args, list):
            # sweep of values
            sweep_args.append([(arg_name, arg) for arg in args])
        elif isinstance(args, dict):
            if "bool" in args:
                # we have a bool argument that has no arg to be passed in with it
                assert args["bool"] is True
                if len(args) == 1:
                    fixed_args += f"--{arg_name}"
                else:
                    # the config arg "values" should be just True and False
                    assert set(args["values"]) == {True, False}
                    if "key" in args:
                        # this arg is swept in parallel with another one, save them all for the end
                        sweep_keys.append(args["key"])
                    else:
                        # this arg is swept independently
                        sweep_args.append([(arg_name, arg) for arg in args["values"]])
            else:
                # if no "key" and no "bool", then sweep values should be specified as a list
                sweep_keys.append(args["key"])

        else:
            # add the fixed argument
            fixed_args += f"--{arg_name} {args} "  # include a space!

    sweep_keys_args = defaultdict(list)
    for sweep_key in sweep_keys:
        for arg_name, args in config.items():
            if isinstance(args, dict) and "key" in args and args["key"] == sweep_key:
                sweep_keys_args[sweep_key].append([(arg_name, arg) for arg in args["values"]])

    for sweep_key in sweep_keys:
        try:
            sweep_key_len, = set(map(len, sweep_keys[sweep_key]))
        except ValueError:
            raise ValueError(f"Got different lengths for sweep key {sweep_key}.")
        sweep_args.append([sweep_keys[sweep_key]])

    return fixed_args, product(sweep_args)


def launch_sweep(args):
    """
    Launch a sweep of jobs.
    """
    fixed_args, sweep_args = parse_config(args.config)

    for sweep_arg in sweep_args:
        j_name = "_".join([f"{arg_name}_{arg}" for arg_name, arg in sweep_arg])
        j_args = fixed_args + " ".join([f"--{arg_name}" if isinstance(arg, bool) else f"--{arg_name} {arg}"
                                        for arg_name, arg in sweep_arg])
        launch_job(args.exp_dir, args.partition, j_name, args.file, j_args, args.q,
                   args.resource, args.cpus_per_task, args.mem, args.exclude, args.ntasks_per_node, args.nodes)


def launch_job(exp_dir, partition, j_name, file, args, q,
               resource, cpus_per_task, mem, exclude=None, ntasks_per_node=1, nodes=1):
    """
    Launch a single job as part of the sweep.
    """
    # set up directories for job
    j_dir = os.path.join(os.getcwd(), exp_dir, j_name)
    j_dir_scripts = os.path.join(j_dir, "scripts")
    j_dir_log = os.path.join(j_dir, "log")
    os.makedirs(j_dir_scripts)
    os.makedirs(j_dir_log)

    # write scripts
    # explicit \n is best according to
    # https://stackoverflow.com/questions/6159900/correct-way-to-write-line-to-file

    # write SLURM script
    slurm_script = os.path.join(j_dir_scripts, f"{j_name}.slrm")
    with open(slurm_script, "w") as f:
        f.write("#!/bin/bash\n")

        # configure SLURM
        f.write(f"#SBATCH --job-name={j_name}\n")
        f.write(f"#SBATCH --output={j_dir_log}/%j.out\n")
        f.write(f"#SBATCH --error={j_dir_log}/%j.err\n")
        f.write(f"#SBATCH --partition={partition}\n")
        f.write(f"#SBATCH --cpus-per-task={cpus_per_task}\n")
        f.write(f"#SBATCH --ntasks-per-node={ntasks_per_node}\n")
        f.write(f"#SBATCH --mem={mem}G\n")
        f.write(f"#SBATCH --nodes={nodes}\n")
        f.write(f"#SBATCH --qos=${q}\n")

        if exclude is not None:
            f.write(f"#SBATCH --exclude={','.join(exclude)}\n")

        if partition != "cpu":
            f.write(f"#SBATCH --gres=gpu:${resource}")

        if q == "deadline":
            f.write("#SBATCH --account=deadline")

        # add command to run job script
        f.write(f"bash ${j_dir}/scripts/${j_name}.sh")

    # write job script
    job_script = os.path.join(j_dir_scripts, f"{j_name}.sh")
    with open(job_script, "w") as f:
        f.write("#!/bin/bash\n")

        # activate environment
        f.write(". /h/$USER/envs/torch.env\n")

        # config checkpoint
        f.write("touch /checkpoint/$USER/\\$SLURM_JOB_ID/DELAYPURGE\n")

        # launch job
        f.write(f"python {file} {args} --save_dir {j_dir} --ckpt_path=/checkpoint/$USER/\\$SLURM_JOB_ID/ck.pt")

    # launch job
    subprocess.run(f"sbatch {slurm_script}")


def main():
    args = get_args()
    args.exp_dir = setup(args)
    launch_sweep(args)


if __name__ == "__main__":
    main()
