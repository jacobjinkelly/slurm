#!/usr/bin/python3

import argparse
import json
import os
import shutil
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from functools import partial
from itertools import product
import math

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
    parser.add_argument("--env", type=str, default="jax_cpu")
    parser.add_argument("--no_save_dir", action="store_true", default=False)
    parser.add_argument("--no_ckpt", action="store_true", default=False)
    parser.add_argument("--resource", type=int, default=1)
    parser.add_argument("--cpus_per_task", type=int, default=1)
    parser.add_argument("--mem", type=int, default=16)
    parser.add_argument("--exclude", type=str, default=None)
    parser.add_argument("--ntasks_per_node", type=int, default=1)
    parser.add_argument("--nodes", type=int, default=1)

    return parser.parse_args()


def run_and_save_cmd(cmd, pipe, shell=True, check=True, **kwargs):
    with open(pipe, "w") as f:
        subprocess.run(cmd, stdout=f, stderr=f, shell=shell, check=check, **kwargs)


def setup(args):
    # create the directory for the sweep
    exp_dir = os.path.join(args.exp_dir, datetime.now().strftime("%F-%H-%M-%S"))
    os.makedirs(exp_dir)

    # copy files for checking sweeps
    shutil.copy("check.py", exp_dir)
    shutil.copy(args.config, exp_dir)

    # record git state
    run_and_save_cmd("git rev-parse HEAD", os.path.join(exp_dir, "commit.state"))
    run_and_save_cmd("git diff", os.path.join(exp_dir, "diff.patch"))

    return exp_dir


def cast_vals(vals, dtype):
    if dtype == "int":
        vals = [int(val) for val in vals]
    return vals


def linspace(start, stop, num, dtype=None):
    step = (stop - start) / (num - 1)
    return cast_vals([start + i * step for i in range(num)], dtype)


def logspace(start, stop, num, dtype, base=10):
    return cast_vals([math.log(val, base) for val in linspace(start, stop, num)], dtype)


def get_vals(args):
    if args["dist"] == "lin":
        val_fun = linspace
    elif args["dist"].startswith("log"):
        base = 10 if args["dist"] == "log" else float(args["dist"][len("log"):])
        val_fun = partial(logspace, base=base)
    elif args["dist"] == "ln":
        val_fun = partial(logspace, base=math.e)
    else:
        raise ValueError(f"Unrecognized dist argument {args['dist']}")
    if "dtype" in args:
        if args["dtype"] == "int":
            dtype = int
        elif args["dtype"] == "float":
            dtype = float
        else:
            raise ValueError(f"Unrecognized dtype {args['dtype']}")
    else:
        dtype = float
    return val_fun(args["start"], args["stop"], args["num"], dtype=dtype)


def parse_config(config_file):
    """
    Parse configuration file for fixed and sweep job hyperparamters.
    """
    with open(config_file, "r") as f:
        config = json.load(f)

    fixed_args = ""
    sweep_args = []
    sweep_keys = set()
    for arg_name, args in config.items():
        if isinstance(args, list):
            # sweep of values
            sweep_args.append([(arg_name, arg) for arg in args])
        elif isinstance(args, dict):
            if "bool" in args:
                # we have a bool argument that has no arg to be passed in with it
                assert args["bool"] is True
                if len(args) == 1:
                    fixed_args += f"--{arg_name} "  # include a space!
                else:
                    # the config arg "values" should be just True and False
                    assert set(args["values"]) == {True, False}
                    if "key" in args:
                        # this arg is swept in parallel with another one, save them all for the end
                        sweep_keys.add(args["key"])
                    else:
                        # this arg is swept independently
                        sweep_args.append([(arg_name, arg) for arg in args["values"]])
            else:
                if "key" in args:
                    sweep_keys.add(args["key"])
                else:
                    sweep_args.append([(arg_name, arg) for arg in get_vals(args)])

        elif isinstance(args, str) or isinstance(args, int) or isinstance(args, float):
            # add the fixed argument
            fixed_args += f"--{arg_name} {args} "  # include a space!
        else:
            raise ValueError(f"Unrecognized argument {args} of type {type(args)}")

    sweep_keys_args = defaultdict(dict)
    for sweep_key in sweep_keys:
        for arg_name, args in config.items():
            if isinstance(args, dict) and "key" in args and args["key"] == sweep_key:
                if "values" in args:
                    sweep_keys_args[sweep_key][arg_name] = args["values"]
                else:
                    sweep_keys_args[sweep_key][arg_name] = [(arg_name, arg) for arg in get_vals(args)]

    for sweep_key in sorted(sweep_keys):
        try:
            sweep_key_len, = set(map(len, sweep_keys_args[sweep_key].values()))
        except ValueError:
            raise ValueError(f"Got different lengths for sweep key {sweep_key}.")
        sweep_args.append([(sweep_key, i) for i in range(sweep_key_len)])

    return fixed_args, product(*sweep_args), sweep_keys_args


def get_single_j_name(arg_name, arg):
    return f"{arg_name}_{arg}"


def get_single_j_arg(arg_name, arg):
    if arg is True:
        return f"--{arg_name}"
    elif arg is False:
        return ""
    else:
        return f"--{arg_name} {arg}"


def get_j(join_str, get_single_j, sweep_arg, sweep_keys):
    j_name_args = []
    for arg_name, arg in sweep_arg:
        if arg_name in sweep_keys:
            for key_arg_name in sorted(sweep_keys[arg_name]):
                j_name_args.append(get_single_j(key_arg_name, sweep_keys[arg_name][key_arg_name][arg]))
        else:
            j_name_args.append(get_single_j(arg_name, arg))
    return join_str.join(j_name_args)


get_j_name = partial(get_j, "_", get_single_j_name)
get_j_args = partial(get_j, " ", get_single_j_arg)


def launch_sweep(args):
    """
    Launch a sweep of jobs.
    """
    fixed_args, sweep_args, sweep_keys = parse_config(args.config)

    for sweep_arg in sweep_args:
        j_name = args.j_name + f"_{get_j_name(sweep_arg, sweep_keys)}" if len(sweep_arg) > 1 else args.j_name
        j_args = fixed_args + get_j_args(sweep_arg, sweep_keys)
        launch_job(args.exp_dir, args.partition, j_name, args.file, j_args, args.q,
                   args.no_save_dir, args.no_ckpt, args.env, args.resource, args.cpus_per_task, args.mem, args.exclude,
                   args.ntasks_per_node, args.nodes)


def launch_job(exp_dir, partition, j_name, file, args, q,
               no_save_dir, no_ckpt, env, resource, cpus_per_task, mem, exclude, ntasks_per_node, nodes):
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
        f.write(f"#SBATCH --qos={q}\n")

        if exclude is not None:
            f.write(f"#SBATCH --exclude={','.join(exclude)}\n")

        if partition != "cpu":
            f.write(f"#SBATCH --gres=gpu:{resource}\n")

        if q == "deadline":
            f.write("#SBATCH --account=deadline\n")

        # add command to run job script
        f.write(f"bash {j_dir}/scripts/{j_name}.sh\n")

    # write job script
    job_script = os.path.join(j_dir_scripts, f"{j_name}.sh")
    with open(job_script, "w") as f:
        f.write("#!/bin/bash\n")

        # activate environment
        f.write(f". /h/$USER/envs/{env}.env\n")

        if not no_save_dir:
            args += f"--save_dir {j_dir}"

        if not no_ckpt:
            # config checkpoint
            f.write("touch /checkpoint/$USER/\\$SLURM_JOB_ID/DELAYPURGE\n")

            args += "--ckpt_path=/checkpoint/$USER/\\$SLURM_JOB_ID/ck.pt"

        # launch job
        f.write(f"python {file} {args}\n")

    # launch job
    subprocess.run(f"sbatch {slurm_script}", shell=True, check=True)


def main():
    args = get_args()
    args.exp_dir = setup(args)
    launch_sweep(args)


if __name__ == "__main__":
    main()
