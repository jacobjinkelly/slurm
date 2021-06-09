#!/usr/bin/python3

import sys
import argparse
import glob

assert sys.version_info.major == 3
assert sys.version_info.minor >= 6

def main():
    parser = argparse.ArgumentParser("Check status of a sweep of jobs")

    # arguments that need to be set for each sweep
    parser.add_argument("-s", "--substr", type=str, default="")

if __name__ == "__main__":
    main()

for log_file in

for log in *${1}*/log.txt; do
    out=$(cat $log | tail -1)
    echo -e $out ' \t ' $log
done
