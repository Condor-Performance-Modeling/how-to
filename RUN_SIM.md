# RUN_CAM Documentation

`run_cam` is a script that facilitates running the performance model.

## Examples

```
run_cam dhry                     # Run the simulator on the Dhrystone workload
run_cam rpt dhry                 # Run Dhrystone and generate a report in this directory
run_cam wfc --no-run             # Run the simulator and write the final config YAML
run_cam --arch medium_core dhry  # Run the simulator using the medium_core arch
```

## Setup


## General info

### Key features
This script has several key features:
- Because this script lives with the simulator, it runs the simulator in the same repo.  This is convenient if you have several repos, each with its own release binary.
- You can run this script in any directory and it will dump the results in the current directory.
- This script facilitates common simulator settings through the use of keywords.

#### Future features
- Specify useful defaults in a user config file ~/.run_cam
- Know where workload repository lives; allow specifying workloads by workload ID.
- Automatically dump simulator parameters so you can specify params with regex.


## Arguments

### -h, `--`help
Display help text.

### -r, `--`rpt
Output report file to the current directory.

### `--`wfc
Write final config YAML to the current directory.
