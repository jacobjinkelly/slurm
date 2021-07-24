# Slurm
Scripts for launching sweeps on SLURM cluster. Originally inspired by [nng555/cluster_examples](https://github.com/nng555/cluster_examples).

## Requirements
Python scripts are compatible using Python 3.6 or higher. Other scripts use bash.

## Usage

### Setup
To set up scripts in a new repository `new_repo`, run
```
./setup.sh new_repo
```
This will symlink scripts for running jobs and copy over example sweep configurations.

### Configuring Sweeps
From the new repo, sweeps can be configured by creating a json file.
See `example.json` for a template example.

Each key in the json file corresponds to a command line argument.
The key can point to a list of values to be swept, a single value to be set, 
or a dictionary.
If the key points to a dictionary, that dictionary can have the following key-value pairs:
- `bool` can be set to True, 
  meaning the command line argument is of the form `--arg` instead of `--arg value`.
- `key` can be set to a string.
  This option can be used to sweep multiple hyperparameters together.
  For example, we may want to set `--dropout 0` if `--batchnorm`, and
  `--dropout .5` if there is no batchnorm.
  See the entires with key `no_dropout_with_bn` in `example.json`.
  Note, this key string CANNOT conflict with the names of any other arguments
  set in the json file.
- `values` can be set to a list of values to sweep over.
  This key should only be set if `key` or `bool` is set, otherwise an error occurs.
  If neither `key` nor `bool` is set, a list of values should be set directly, without using a dictionary.
  If `bool` is set, then `values` must be a subset of `{true, false}`.
  If `key` is set, then `values` must be the same length across all entries with the same `key`.

### Launching Sweeps

A job sweep can be launched as follows:

```
./batch.py -c example.json -p PARTITION -j JOB_NAME -f FILE_TO_RUN -q SLURM_QOS
```

The output of the job will be saved by default in `experiments/${DATE_TIME}`, 
with a directory for each configuration of hyperparameters being swept over.

## Issues
If a job preempts after a new update to the repo has been pulled in, when the job relaunches it will run 
the newly updated code.
Thus, to prevent any potential problems, it is best practice to make pulled changes backwards compatible 
while jobs are in progress.
