#!/usr/bin/python3

import argparse
import subprocess


def main():
    parser = argparse.ArgumentParser("Download an experiment directory")

    parser.add_argument("-t", "--timestamp", type=str, required=True, help="Timestamp of experiment")
    parser.add_argument("-t", "--timestamp", type=str, help="Remote root directory")

    args = parser.parse_args()

    # -a: recurse into subdirectories, turn on archive mode and all other options
    # -v: verbose
    # -e: use ssh for encryption
    # --exclude: exclude all checkpoint files (large and unnecessary)

    cmd = f"rsync -av -e ssh --exclude='*.pt' vd:/h/jkelly/zero-shot/experiments/{args.timestamp}/ {args.timestamp}/"
    subprocess.run(cmd, shell=True, check=True)


if __name__ == "__main__":
    main()
