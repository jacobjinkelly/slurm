# Cluster
Shell scripts for managing jobs with SLURM. Modified from [nng555/cluster_examples](https://github.com/nng555/cluster_examples).

## Usage
`launch_batch.sh` can be used to launch a single job or a batch of jobs. It generates a time-stamped folder `YYYY-MM-DD-HH-mm-SS` at the time of launching a batch. This directory will contain a separate subdirectory for each job with a different configuration of hyperparameters.

## Issues
- If the file to be run passed to `launch_batch.sh` is changed, that new version will be run when the job is submitted to the queue (either due to waiting or preemption). One solution is to copy the file into the job directory and create the job script from there.
