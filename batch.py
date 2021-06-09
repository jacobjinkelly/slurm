#!/usr/bin/python3

import sys
import argparse

print("Hello world")

assert sys.version_info.major == 3
assert sys.version_info.minor > 6


def main():
    parser = argparse.ArgumentParser("Launch a sweep of jobs")


if __name__ == "__main__":
    main()
