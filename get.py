#!/usr/bin/python3

import argparse
import subprocess


def main():
    parser = argparse.ArgumentParser("Download an experiment directory")

    parser.add_argument("-t", "--timestamp", type=str, required=True, help="Timestamp of experiment")

    args = parser.parse_args()

    cmd = "rsync -av -e ssh --exclude='*.pt' vd:/h/jkelly/zero-shot/experiments/${exp_dir}/ ${exp_dir}/"
    subprocess.run(cmd, shell=True, check=True)


if __name__ == "__main__":
    main()
