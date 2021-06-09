#!/bin/bash
for log in */log.txt; do
    out=$(cat $log | tail -1)
    echo -e $out ' \t ' $log
done
