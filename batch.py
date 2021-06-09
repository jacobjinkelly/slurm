#!/usr/bin/python3

import sys
import argparse

print("Hello world")

assert sys.version_info.major == 3
assert sys.version_info.minor > 6


def main():
    parser = argparse.ArgumentParser("Launch a sweep of jobs")

    parser.add_argument("--partition", type=str, default="t4v2")


if __name__ == "__main__":
    main()
