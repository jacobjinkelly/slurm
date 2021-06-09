# Cluster
Scripts for launching sweeps on SLURM. Modified from [nng555/cluster_examples](https://github.com/nng555/cluster_examples).

## Requirements
All scripts are compatible using Python 3.6, and presumably higher versions. 
Some scripts also use bash.

## Usage

### Setup
To set up scripts in a new repo `new_repo`, simply run
```
./setup.sh new_repo
```


### Configuring Sweeps
From the new repo, sweeps can be configured by creating a json file.
See `example.json` for a template example.

Each key in the json file corresponds to a command line argument.
The key can point to a list of values to be swept, a single value to be set, 
or a dictionary.
If the key points to a dictionary, that dictionary can have the following keys set.
- The `bool` key can be set to True, 
  meaning the command line argument is of the form `--arg` instead of `--arg value`.
- The `key` flag can be set to a string. Note, this key string CANNOT conflict with 
  any command line arguments being configured in the sweep.
  This option can be used to sweep multiple hyperparameters together.
  For example, we may want to set `--dropout 0` if `--batchnorm`.
  We could set the key to be `no_dropout_with_bn`.
- The `values` key can be set to a list of values.
  If `key` and `bool` are not set, then we can just pass in a list directly.
  If `bool` is set, the only option for this is `[true, false]`.
  If `key` is set, then `values` must be the same length across all entries with the same `key`.

### Launching Sweeps

Once the sweep is configured, the job can be launched as follows.
```
./batch.py
```

## Issues
- If the file to be run passed to `launch_batch.sh` is changed, that new version will be run when the job is submitted to the queue (either due to waiting or preemption). One solution is to copy the file into the job directory and create the job script from there.
