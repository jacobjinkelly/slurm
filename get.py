#!/usr/bin/python3

import argparse
import subprocess


def main():
    parser = argparse.ArgumentParser("Download an experiment directory")

    parser.add_argument("-t", "--timestamp", type=str, required=True, help="Timestamp of experiment")
    parser.add_argument("-r", "--root", type=str, default="/h/jkelly/kfac-pytorch/experiments/",
                        help="Remote root directory")
    parser.add_argument("-h", "--host", type=str, default="vd", help="SSH host")

    args = parser.parse_args()

    # -a: recurse into subdirectories, turn on archive mode and all other options
    # -v: verbose
    # -e: use ssh for encryption
    # --exclude: exclude all checkpoint files (large and unnecessary)

    cmd = f"rsync -av -e ssh --exclude='*.pt' {args.host}:{args.root}/{args.timestamp}/ {args.timestamp}/"
    subprocess.run(cmd, shell=True, check=True)


if __name__ == "__main__":
    main()
