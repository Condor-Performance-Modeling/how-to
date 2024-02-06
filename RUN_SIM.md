# RUN_SIM Documentation

`run_sim` is a script that facilitates running the performance model.

## Examples

```
run_sim dhry                                 # Run the simulator on the Dhrystone workload
run_sim -ro dhry                             # Run Dhrystone and send both report and stdout to this directory
run_sim --wfc --no-run                       # Write the default final config YAML to this directory without running a workload
run_sim -ro --arch cuzco_arch dhry           # Run the simulator using the cuzco_arch arch, writing results to this directory
run_sim -o --arch cuzco_arch --wfc --no-run  # Write the cuzco_arch final config YAML to this directory without running a workload

# Example of specifying a parameter
run_sim -ro --arch cuzco_arch -p top.cpu.core0.fetch.params.num_to_fetch 12 dhry

# Example of running only the first 1000 instructions
run_sim -ro --arch cuzco_arch -i 1k dhry
```

## Setup
(This section TBD; talks about setting up config files)

## General info

### Key features
This script has several key features:
- Because this script lives with the simulator, it runs the simulator in the same repo.  This is convenient if you have several repos, each with its own release binary.
- You can run this script in any directory and it will dump the results in the current directory.
- This script facilitates common simulator settings through the use of keywords.

#### Future features
- Specify useful defaults in a user config file ~/.run_sim
- Know where workload repository lives; allow specifying workloads by workload ID.
- Automatically dump simulator parameters so you can specify params with regex.

## Workload ID
When specifying a workload, you may supply a numeric workload ID.  `run_sim` will then look for this workload in the `$TRACELIB` directory.

For example:
```
run_sim -ro 7
```
will find this workload:
```
$TRACELIB/0001/007/bzip2_dryer_test_7_91_2024-02-01_100m_0.0689655.zstf
```

## Arguments

### `-h`, `--help`
Display help text.

## `--`
Eat all remaining arguments, passing them directly to the simulator.

Example:
```
run_sim -ro dhry -- --foo --bar
```

would pass `--foo --bar` directly to the simulator.

### `--ARG VAL`
Any pair of arguments in this form (if `run_sim` doesn't recognize `--ARG`) are passed to the simulator.  For example:

Example:
```
run_sim --arch cuzco_arch dhry
```

Note:  it is assumed the param takes exactly one value.  To pass other types of args directly to the simulator, use `--`.

### `-i INSTS`
Limit the number of instructions to INSTS.  Understand common abbreviations like `k` = 1000 and `m` = 1,000,000

Example:
```
run_sim -ro --arch cuzco_arch -i 1k dhry     # Stop after running the first 1000 instructions
```

### `--no-run`
Do not run simulator.

### `-o`
Redirect stdout to file in default directory.

### `-p PARAM VALUE`
Specify param/value pair in simulator.

Example:
```
run_sim -ro --arch cuzco_arch -p top.cpu.core0.fetch.params.num_to_fetch 12 dhry
```

### `-q`
Generate and display command line, but don't invoke simulator.

### `-r`, `--rpt`
Output report file to the current directory.

### `--wfc`
Write final config YAML to the current directory.

Usually used with `--no-run`

Example:
```
run_sim --arch cuzco_arch --wfc --no-run
```

### `--wkld WLKD`
This is an alternate way to specify a workload, which may be useful in certain scripting situations.

These two commands are equivalent:
```
run_sim dhry
run_sim --wkld dhry
```
