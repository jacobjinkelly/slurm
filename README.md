# Slurm
Scripts for launching hyperparameter sweeps on a SLURM cluster.

## Requirements
Python scripts are compatible using Python 3.6 or higher, using only standard libraries. Other scripts use bash.

## Usage

### Setup
To set up scripts in a new repository `new_repo`, run
```
./setup.sh new_repo
```
This will symlink scripts for running jobs and copy over example sweep configurations.

### Configuring Sweeps
From the new repository, sweeps can be configured by creating a json file.
For an example, see `example.json`.

Each key in the json file corresponds to a separate command line argument.
The key can point to a list of values to be swept, a single value to be set, 
or a dictionary.

If the key points to a dictionary, that dictionary can have the following key-value pairs:
- `key` must be a string.
  This option can be used to sweep multiple hyperparameters together.
  For example, we may want to set `--dropout 0` if `--batchnorm`, and
  `--dropout .5` if there is no batchnorm.
  See the entries with key `no_dropout_with_bn` in `example.json` for an example.
  Note, this key string CANNOT conflict with the names of any other arguments
  set in the json file.
- `values` must be a list of values to be swept over. It should be the same length for 
  all arguments with the same sweep `key`.
- `dist`, `start`, `stop`, `num` can be specified instead of `values`.
  `dist` gives the distribution of values to be swept over (`lin`, `ln`, or (base 10) `log`).
  A custom base of log can be specified by appending a number after `log`, e.g. `log2`, `log3`, `log1.5`.
  `start` and `stop` give the left and right endpoints for the values, and `num` gives the number of values
  to use. Additionally, `dtype` can be specified to `float` (default) or `int`.
- `one_hot_sweep` can be specified instead of `values`. This argument can be used to sweep over a `key` consisting of
  all boolean values by turning on exactly one of them at a time. For example, we may want to try `--batch_norm`, `--group_norm`,
  and `--layer_norm` individually.

If the key points to a bool (`true` or `false`), then the arg will be set as `--arg` instead of `--arg [value]`.

### Launching Sweeps

A job sweep can be launched as follows:

```
./batch.py PARTITION JOB_NAME FILE_TO_RUN SLURM_QOS CONFIG
```

The output of the job will be saved by default in `experiments/YYYY-MM-DD-HH-MM-SS`, 
with a directory for each configuration of hyperparameters in the sweep.

## Issues
If a job preempts after a new update to the repo has been pulled in, when the job relaunches it will run 
the newly updated code.
Thus, to prevent any potential problems, it is best practice to make pulled changes backwards compatible 
while jobs are in progress.

## Acknowledgements

Originally inspired by [nng555/cluster_examples](https://github.com/nng555/cluster_examples).
