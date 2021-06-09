# Cluster
Scripts for launching sweeps on SLURM. Modified from [nng555/cluster_examples](https://github.com/nng555/cluster_examples).

## Requirements
All scripts are compatible using Python 3.6, and presumably higher versions. 
Some scripts also use bash.

## Usage
To set up scripts in a new repo `new_repo`, simply run
```
./setup.sh new_repo
```

From the new repo, sweeps can be configured by creating a json file.
See `example.json` for a template.

Each key in the json file corresponds to a command line argument.
The key can point to a list of values to be swept, a single value to be set, 
or a dictionary.
If the key

Once the sweep is configured, the job can be launched as follows.

```
./batch.py
```

## Issues
- If the file to be run passed to `launch_batch.sh` is changed, that new version will be run when the job is submitted to the queue (either due to waiting or preemption). One solution is to copy the file into the job directory and create the job script from there.
