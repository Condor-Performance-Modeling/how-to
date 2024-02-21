# RUN_SIM Documentation

`run_sim` is a script that facilitates running the performance model.

## Examples

```
run_sim dhry                                 # Run the simulator on the Dhrystone workload
run_sim -ro dhry                             # Run Dhrystone and send both report and stdout to this directory
run_sim --wfc --no-run                       # Write the default final config YAML to this directory without running a workload
run_sim -ro --arch cuzco dhry                # Run the simulator using the cuzco arch, writing results to this directory
run_sim -o --arch cuzco --wfc --no-run       # Write the cuzco final config YAML to this directory without running a workload

# Examples of specifying a parameter
run_sim -ro --arch cuzco -p top.cpu.core0.fetch.params.num_to_fetch 12 dhry
run_sim -ro --arch cuzco -P 'num.*fetch' 12 dhry

# Example of running only the first 1000 instructions
run_sim -ro --arch cuzco -i 1k dhry

# Example of running the workload and also writing the final config YAML
run_sim -ro --arch cuzco --wfc dhry
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
- Automatically dump simulator parameters so you can specify params with regex

## Workload ID
When specifying a workload, you may supply a numeric workload ID in the form `BBBBNNN`, where `BBBB` is the 4-digit bundle ID and `NNN` is the 3-digit index of the workload within the bundle.  `run_sim` will then look for this workload in the `$TRACELIB` directory, in `$TRACELIB/BBBB/NNN/`.  For further details, see https://condorcomp.atlassian.net/wiki/spaces/PerfModel1/pages/250150935/Workload+Tracing+and+Methodology

For example:
```
run_sim -ro 1007
```
will find this workload:
```
$TRACELIB/0001/007/bzip2_dryer_test_7_91_2024-02-01_100m_0.0689655.zstf
```

## Parameter Regexes
The [-P](#-p-regex-value) and [-M](#-m-regex-value) options allow specifying a parameter regex rather than the full parameter name.  For example, `-P 'num.*fetch' 12` is equivalent to `-p top.cpu.core0.fetch.params.num_to_fetch 12`.

You can also use this to search for relevant parameters, for example:
```
$ run_sim -ro --arch cuzco -P fetch foo -q
run_sim: error: Param regex "fetch" matches more than one param:
- top.cpu.core0.fetch.params.num_to_fetch
- top.cpu.core0.fetch.params.skip_nonuser_mode
- top.cpu.core0.fetch.params.input_file
- top.cpu.core0.fetch.params.statpred_accuracy
- top.cpu.core0.fetch.params.statpred_seed
```

You may also set multiple params at the same time, such as parameters that are replicated across multiple units:
```
$ run_sim -ro --arch cuzco -M scheduler_size 12 -q
```
which sets all of the following parameters to 12:
- `top.cpu.core0.execute.iq0.params.scheduler_size`
- `top.cpu.core0.execute.iq1.params.scheduler_size`
- `top.cpu.core0.execute.iq2.params.scheduler_size`
- `top.cpu.core0.execute.iq3.params.scheduler_size`

Some important considerations with parameter regexes are mentioned below.

### Parameters are cached in a file
The list of available parameters is obtained by running the simulator with `--write-final-config` and `--no-run`, parsing the output YAML, and storing the results in a params cache file that lives with the simulator.  If the simulator's modification time changes, the params cache file is regenerated.  The params cache file may also be manually deleted to force it to be regenerated.

### The parameter cache file is not locked
File locking has not been added to the params cache file, so for now care must be taken to not thrash this file with simultaneous writes or out-of-date reads.  In situations with simultaneous accesses (such as running a study), it is recommended that these steps be followed:

1.  The simulator is run once in the beginning (as part of sanity checking that the simulator works) to generate an up-to-date params cache file for all the runs.
2.  Each of the simultaneous runs can then read the params cache file without trying to regenerate the parameters.  For added safety, these runs should use the `--no-write-params-cache` option.

### Parameter regexes are topology-based
The params cache file contains a different set of params for each topology.  Topology detection is currently fairly primitive:  it is based on the `--arch` specified.  For example, running with these two commands:
```
run_sim --arch cuzco ...
run_sim --arch small_core ...
```
would store two different sets of parameters in the params cache.

Any other topology changes (such as made by specifying `-p` options) are not currently detected and would need to be added to `run_sim` as needed.

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
run_sim --arch cuzco dhry
```

Note:  it is assumed the param takes exactly one value.  To pass other types of args directly to the simulator, use `--`.

### `--dbg INSTS`
Dump debug and info at `top` node, starting at this inst count.  Usually used with `-i`.

Example:
```
run_sim -ro --arch cuzco --dbg 1k -i 2k dhry   # Dump debug and info between 1000 and 2000 instructions
```

### `--dbgn NODE INSTS`
Dump debug and info at `NODE` node, starting at this inst count.  Usually used with `-i`.

Example:
```
run_sim -ro --arch cuzco --dbgn top.cpu.core0.rename 1k -i 2k dhry   # Dump debug and info for rename unit between 1000 and 2000 instructions
```

### `--dbglsu INSTS`
Dump debug and info at `top.cpu.core0.lsu` node, starting at this inst count.  Usually used with `-i`.

Example:
```
run_sim -ro --arch cuzco --dbglsu 1k -i 2k dhry   # Dump debug and info for lsu unit between 1000 and 2000 instructions
```

### `-i INSTS`, `--insts INSTS`
Limit the number of instructions to INSTS.  Understand common abbreviations like `k` = 1000 and `m` = 1,000,000

Example:
```
run_sim -ro --arch cuzco -i 1k dhry     # Stop after running the first 1000 instructions
```

### `-M REGEX VALUE`
Same as `-P`, but allow multi-matches.  For example:
```
run_sim -ro --arch cuzco -M scheduler_size 12 --wfc dhry
```
would set all of these parameters to `12`:
- `top.cpu.core0.execute.iq0.params.scheduler_size`
- `top.cpu.core0.execute.iq1.params.scheduler_size`
- `top.cpu.core0.execute.iq2.params.scheduler_size`
- `top.cpu.core0.execute.iq3.params.scheduler_size`

See [Parameter Regexes](#parameter-regexes) for more information.

### `--no-run`
Do not run simulator.

### `--no-write-params-cache`
Do not write the params cache file

### `-o`
Redirect stdout to file in default directory.

### `-p PARAM VALUE`
Specify param/value pair in simulator.

Example:
```
run_sim -ro --arch cuzco -p top.cpu.core0.fetch.params.num_to_fetch 12 dhry
```

### `-P REGEX VALUE`
Specify param regex/value pair in simulator.

Example:
```
run_sim -ro --arch cuzco -P 'num.*fetch` 12 --wfc dhry
```
would set the parameter `top.cpu.core0.fetch.params.num_to_fetch` to `12`.

This is also a convenient way to list relevant parameters.  For example:
```
$ run_sim --arch cuzco -P scheduler_size foo -q
run_sim: error: Param regex "scheduler_size" matches more than one param:
- top.cpu.core0.execute.iq0.params.scheduler_size
- top.cpu.core0.execute.iq1.params.scheduler_size
- top.cpu.core0.execute.iq2.params.scheduler_size
- top.cpu.core0.execute.iq3.params.scheduler_size
```
See [Parameter Regexes](#parameter-regexes) for more information.

### `-q`
Generate and display command line, but don't invoke simulator.

### `-r`, `--rpt`
Output report file to the current directory.

### `--wfc`
Write final config YAML to the current directory.

Usually used with `--no-run`

Example:
```
run_sim --arch cuzco --wfc --no-run
```

### `--wkld WLKD`
This is an alternate way to specify a workload, which may be useful in certain scripting situations.

These two commands are equivalent:
```
run_sim dhry
run_sim --wkld dhry
```
