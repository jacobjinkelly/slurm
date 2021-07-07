#!/usr/bin/python3

import argparse
import subprocess


def main():
    parser = argparse.ArgumentParser("Download an experiment directory")

    parser.add_argument("-t", "--timestamp", type=str, required=True, help="Timestamp of experiment")


if __name__ == "__main__":
    main()
