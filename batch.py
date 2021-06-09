#!/usr/bin/python3

import argparse
import os
import sys
import shutil
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


def main():
    args = get_args()

    exp_dir = os.path.join(args.experiment_dir, datetime.now().strftime("%F-%H-%M-%S"))
    os.makedirs(exp_dir)

    print(exp_dir)


if __name__ == "__main__":
    main()
