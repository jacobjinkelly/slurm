#!/bin/bash

# target must be an absolute path, otherwise symlinks won't work
target=${1}

cp example.json "${target}"/

for f in batch.py check.py cancel.sh; do
    ln -s $(pwd)/${f} "${target}"/${f}
done
