#!/usr/bin/python3

import argparse
import os
import shutil
import sys
import subprocess
import json
from datetime import datetime

assert sys.version_info.major == 3
assert sys.version_info.minor >= 6


def get_args():
    parser = argparse.ArgumentParser("Launch a sweep of jobs")

    # arguments that will be set for most sweeps
    parser.add_argument("-p", "--partition", type=str, default="t4v2")
    parser.add_argument("-j", "--j_name", type=str, required=True)
    parser.add_argument("-f", "--file", type=str, required=True)
    parser.add_argument("-a", "--args", type=str)
    parser.add_argument("-q", "--q", type=str, required=True)
    parser.add_argument("-c", "--config", type=str, required=True)

    # default arguments that will rarely be changed
    parser.add_argument("--experiment_dir", type=str, default="experiments")

    return parser.parse_args()


def run_cmd(cmd, pipe, shell=True, check=True, capture_output=True, **kwargs):
    with open(pipe, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=f, shell=shell, check=check, capture_output=capture_output, **kwargs)


def setup(args):
    # create the directory for the sweep
    exp_dir = os.path.join(args.experiment_dir, datetime.now().strftime("%F-%H-%M-%S"))
    os.makedirs(exp_dir)

    # copy files for checking sweeps
    shutil.copy("check.sh", exp_dir)
    shutil.copy("param_check.sh", exp_dir)

    # record git state
    run_cmd("git rev-parse HEAD", os.path.join(exp_dir, "commit.state"))
    run_cmd("git diff", os.path.join(exp_dir, "diff.patch"))


def parse_config(config_file):
    """
    Parse configuration file for fixed and sweep job hyperparamters.
    """
    with open(config_file, "r") as f:
        config = json.load(f)

    # for fixed args, we just need to return a string for argparse to parse later on

    fixed_args = ""
    for arg_name, args in config.items():
        if isinstance(args, list):
            # sweep of values
            pass
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
                        # this arg is swept in parallel with another one
                        # TODO
                        assert False
                    else:
                        # this arg is swept independently
                        # TODO
                        assert False
            else:
                if "key" in args:
                    # this arg is swept in parallel with another one
                    # TODO
                    assert False
                else:
                    # this arg is swept independently
                    # TODO
                    assert False

        else:
            # add the fixed argument
            fixed_args += f"--{arg_name} {args} "  # include a space!

    return fixed_args


def launch_sweep(args):
    """
    Launch a sweep of jobs.
    """
    parse_config(args.config)


def launch_job(exp_dir, partition, j_name, file, args, q, resource, cpus_per_task, mem,
               exclude=None, ntasks_per_node=1, nodes=1):
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
            f.write(f"#SBATCH --exclude={exclude.join(',')}\n")

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
    setup(args)
    launch_sweep(args)


if __name__ == "__main__":
    main()
