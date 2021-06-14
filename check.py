#!/usr/bin/python3

import sys
import argparse
from glob import glob

assert sys.version_info.major == 3
assert sys.version_info.minor >= 6


def get_args():
    parser = argparse.ArgumentParser("Check status of a sweep of jobs")

    # arguments that need to be set for each sweep
    parser.add_argument("-s", "--substr", type=str, default="")
    parser.add_argument("-f", "--file", type=str, default="log.txt")
    parser.add_argument("-l", "--line", type=int, default=-1)
    parser.add_argument("-n", "--name", action="store_true", default=False)

    return parser.parse_args()


def main():
    args = get_args()

    for log_file in glob(f"*{args.substr}*/{args.file}"):
        with open(log_file, "r") as f:
            line = f.readlines()[args.line].rstrip()
            if args.name:
                print(f"{line}\t{log_file}")
            else:
                print(line)


if __name__ == "__main__":
    main()
