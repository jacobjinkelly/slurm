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


def launch_job(exp_dir, partition, j_name, file, args, q, resource):
    """
    Launch a single job as part of the sweep.
    """
    # set up directories for job
    j_dir = os.path.join(os.getcwd(), exp_dir, j_name)
    os.makedirs(os.path.join(j_dir, "scripts"))
    os.makedirs(os.path.join(j_dir, "log"))

    # configure SLURM options


def main():
    args = get_args()

    setup(args)


if __name__ == "__main__":
    main()
