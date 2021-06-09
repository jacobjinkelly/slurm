#!/bin/bash

target=${1}

for f in batch.py check.py cancel.sh; do
    ln -s ${f} ${target}/${f}
done
