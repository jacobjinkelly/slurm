#!/usr/bin/python3

import sys
import argparse
import glob

assert sys.version_info.major == 3
assert sys.version_info.minor >= 6


def get_args():
    parser = argparse.ArgumentParser("Check status of a sweep of jobs")

    # arguments that need to be set for each sweep
    parser.add_argument("-s", "--substr", type=str, default="")
    parser.add_argument("-f", "--file", type=str, default="log.txt")

    return parser.parse_args()


def main():
    args = get_args()

    for log in glob(f"*{args.substr}/{args.file}"):
        pass


if __name__ == "__main__":
    main()
