#!/usr/bin/python3

import argparse
import os
import shutil
import sys
import subprocess
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

    # write SLURM script
    slurm_script = os.path.join(j_dir_scripts, f"{j_name}.slrm")
    with open(slurm_script, "w") as f:
        # explicit \n is best according to
        # https://stackoverflow.com/questions/6159900/correct-way-to-write-line-to-file

        # configure SLURM
        f.write("#!/bin/bash\n")
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

        # run job
        f.write(f"bash ${j_dir}/scripts/${j_name}.sh")


def main():
    args = get_args()

    setup(args)


if __name__ == "__main__":
    main()
