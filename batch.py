#!/usr/bin/python3

import sys
import argparse

assert sys.version_info.major == 3
assert sys.version_info.minor >= 6


def main():
    parser = argparse.ArgumentParser("Launch a sweep of jobs")

    parser.add_argument("-p", "--partition", type=str, default="t4v2")
    parser.add_argument("-j", "--j_name", type=str, required=True)
    parser.add_argument("-f", "--file", type=str, required=True)
    parser.add_argument("-a", "--args", type=str)
    parser.add_argument("-q", "--q", type=str, required=True)

    args = parser.parse_args()


if __name__ == "__main__":
    main()
