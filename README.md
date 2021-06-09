# Cluster
Scripts for launching sweeps on SLURM cluster. Originally inspired by [nng555/cluster_examples](https://github.com/nng555/cluster_examples).

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
If the key points to a dictionary, that dictionary can have the following keys:
- `bool` can be set to True, 
  meaning the command line argument is of the form `--arg` instead of `--arg value`.
- `key` can be set to a string.
  This option can be used to sweep multiple hyperparameters together.
  For example, we may want to set `--dropout 0` if `--batchnorm`.
  We could set the key to be `no_dropout_with_bn`.
  Note, this key string CANNOT conflict with 
  any command line arguments being configured in the sweep.
- The `values` key can be set to a list of values.
  If `key` and `bool` are not set, then an error is thrown as we can just 
  directly pass in a list of values for this hyperparameter instead of a dictionary.
  If `bool` is set, the only option for this is `[true, false]`.
  If `key` is set, then `values` must be the same length across all entries with the same `key`.

### Launching Sweeps

Once the sweep is configured, the job can be launched as follows.
```
./batch.py -c example.json -p PARTITION -j JOB_NAME -f FILE_TO_RUN -q SLURM_QOS
```

The output of the job will be saved by default in `experiments/${DATE_TIME}`, 
with a directory for each configuration of hyperparameters being swept over.

## Issues
There is a potential issue if a job is preempted after a new update to the repo has been pulled in.
When the preempted job is relaunched it will run the newly updated code, and not the 
original code it was run with. 
A solution to this would be to clone the entire repo each time
a job is launched. 
This would slow down launching a sweep and put unneeded work on the login node by cloning
the repo many times.
The current solution is to make changes backwards compatible while jobs are in progress
if pulling new updates to the repo is required, or simply not pulling
new updates.
