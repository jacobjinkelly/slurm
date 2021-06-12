#!/bin/bash

exp_dir=${1}  # timestamp directory of experiment

# -a: recurse into subdirectories, turn on archive mode and all other options
# -v: verbose
# -e: use ssh for encryption
# --exclude: exclude all checkpoint files (large and unnecessary)
rsync -av -e ssh --exclude='*.pt' vd:/h/jkelly/zero-shot/experiments/${exp_dir}/ ${exp_dir}/
