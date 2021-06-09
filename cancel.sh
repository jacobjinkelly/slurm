#!/bin/bash
for i in $(seq 2022950 2022974); do
  scancel "$i"
done
