#!/usr/bin/python3

import argparse
import json
import math
import os
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from functools import partial
from itertools import product

assert sys.version_info.major == 3
assert sys.version_info.minor >= 6


def get_args():
    parser = argparse.ArgumentParser("Launch a sweep of jobs")

    # positional arguments that need to be set for each sweep
    parser.add_argument("partition", type=str)
    parser.add_argument("j_name", type=str)
    parser.add_argument("file", type=str)
    parser.add_argument("qos", type=str)
    parser.add_argument("config", type=str)

    # keyword arguments with defaults that don't need to be changed often
    parser.add_argument("--exp_dir", type=str, default="experiments")
    parser.add_argument("--env", type=str, default="torch")
    parser.add_argument("--no_save_dir", action="store_true", default=False)
    parser.add_argument("--no_ckpt", action="store_true", default=False)
    parser.add_argument("--resource", type=int, default=1)
    parser.add_argument("--cpus_per_task", type=int, default=1)
    parser.add_argument("--mem", type=int, default=16)
    parser.add_argument("--exclude", nargs="+", type=str, default=[])
    parser.add_argument("--ntasks_per_node", type=int, default=1)
    parser.add_argument("--nodes", type=int, default=1)
    parser.add_argument("--env_vars", type=str, default="")

    # configure test mode (don't actually run command to launch jobs)
    parser.add_argument("--test_mode", action="store_true", default=False)

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


def cast_dtype(vals, dtype):
    if dtype == "int":
        vals = [int(val) for val in vals]
    elif dtype == "float" or dtype is None:
        pass
    else:
        raise ValueError(f"Unrecognized dtype {dtype}")
    return vals


def linspace(start, stop, num, dtype=None):
    step = (stop - start) / (num - 1)
    return cast_dtype([start + i * step for i in range(num)], dtype)


def logspace(start, stop, num, dtype, base=10):
    return cast_dtype([math.pow(base, val) for val in linspace(start, stop, num)], dtype)


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
    dtype = args["dtype"] if "dtype" in args else "float"
    return val_fun(args["start"], args["stop"], args["num"], dtype=dtype)


def dict_raise_on_duplicates(ordered_pairs):
    """
    Reject duplicate keys since by default, json allows them.
    """
    d = {}
    for k, v in ordered_pairs:
        if k in d:
            raise ValueError("duplicate key: %r" % (k,))
        else:
            d[k] = v
    return d


def parse_config(config_file):
    """
    Parse configuration file for fixed and sweep job hyperparamters.
    """
    with open(config_file, "r") as f:
        config = json.load(f, object_pairs_hook=dict_raise_on_duplicates)

    fixed_args = ""
    sweep_args = []
    sweep_keys = set()
    for arg_name, args in config.items():
        if isinstance(args, list):
            # sweep of values
            sweep_args.append([(arg_name, arg) for arg in args])
        elif isinstance(args, dict):
            if "key" in args:
                sweep_keys.add(args["key"])
            else:
                sweep_args.append([(arg_name, arg) for arg in get_vals(args)])
        elif isinstance(args, bool):  # check first, since bool is also an int
            if args is not True:
                raise ValueError(f"Got redundant specification {arg_name}: {args}. "
                                 f"{arg_name} should only be specified if it needs to be set to True.")
            # add fixed bool argument
            fixed_args += f"--{arg_name} "  # include a space!
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
                    sweep_keys_args[sweep_key][arg_name] = get_vals(args)

    for sweep_key in sorted(sweep_keys):
        try:
            sweep_key_len, = set(map(len, sweep_keys_args[sweep_key].values()))
        except ValueError:
            raise ValueError(f"Got different lengths for sweep key {sweep_key}.")
        sweep_args.append([(sweep_key, i) for i in range(sweep_key_len)])

    return fixed_args, product(*sweep_args), sweep_keys_args


def get_single_j_name(arg_name, arg):
    """
    Modified from https://github.com/django/django/blob/master/django/utils/text.py.
    Process arg to remove any filesystem-sensitive characters.
    """
    arg = str(arg)
    if "/" in arg:
        arg = re.sub(r'[^\w\s-]', '', arg.lower())
        arg = re.sub(r'[-\s]+', '-', arg).strip('-_')
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
        j_name = args.j_name + f"_{get_j_name(sweep_arg, sweep_keys)}" if len(sweep_arg) > 0 else args.j_name
        j_args = fixed_args + get_j_args(sweep_arg, sweep_keys)
        launch_job(args, j_name, j_args)


def launch_job(args, j_name, j_args):
    """
    Launch a single job as part of the sweep.
    """
    # set up directories for job
    j_dir = os.path.join(os.getcwd(), args.exp_dir, j_name)
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
        f.write(f"#SBATCH --partition={args.partition}\n")
        f.write(f"#SBATCH --cpus-per-task={args.cpus_per_task}\n")
        f.write(f"#SBATCH --ntasks-per-node={args.ntasks_per_node}\n")
        f.write(f"#SBATCH --mem={args.mem}G\n")
        f.write(f"#SBATCH --nodes={args.nodes}\n")
        f.write(f"#SBATCH --qos={args.qos}\n")

        if args.exclude is not None:
            f.write(f"#SBATCH --exclude={','.join(args.exclude)}\n")

        if args.partition != "cpu":
            f.write(f"#SBATCH --gres=gpu:{args.resource}\n")

        if args.qos == "deadline":
            f.write("#SBATCH --account=deadline\n")

        # add command to run job script
        f.write(f"bash {j_dir}/scripts/{j_name}.sh\n")

    # write job script
    job_script = os.path.join(j_dir_scripts, f"{j_name}.sh")
    with open(job_script, "w") as f:
        f.write("#!/bin/bash\n")

        # activate environment
        f.write(f". /h/$USER/envs/{args.env}.env\n")

        if not args.no_save_dir:
            args += f" --save_dir {j_dir} "

        if not args.no_ckpt:
            # config checkpoint
            f.write("touch /checkpoint/$USER/$SLURM_JOB_ID/DELAYPURGE\n")

            args += " --ckpt_path=/checkpoint/$USER/$SLURM_JOB_ID/ck.pt "

        # launch job
        f.write(f"{args.env_vars} python {args.file} {j_args}\n")

    # launch job
    subprocess.run(f"sbatch {slurm_script}", shell=True, check=True)


def main():
    args = get_args()
    args.exp_dir = setup(args)
    launch_sweep(args)


if __name__ == "__main__":
    main()
