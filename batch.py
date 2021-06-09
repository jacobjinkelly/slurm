#!/usr/bin/python3

import sys
import argparse

print("Hello world")

assert sys.version_info.major == 3
assert sys.version_info.minor > 6


def main():
    parser = argparse.ArgumentParser("Launch a sweep of jobs")

    parser.add_argument("--partition", type=str, default="t4v2")
    parser.add_argument("--j_name", type=str, required=True)
    parser.add_argument("--file", type=str, required=True)
    parser.add_argument("--args", type=str)
    parser.add_argument("--q", type=str, required=True)

    args = parser.parse_args()


if __name__ == "__main__":
    main()
