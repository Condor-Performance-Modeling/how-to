# SET-LOCAL-ENV.md

Environment setup for the Condor-Performance-Modeling organization.

--------------------------------------
# ToC

1. [Set local environment variables](#set-local-environment-variables)

--------------------------------------
# Set local environment variables

Bash environment variables are presumed in the instructions that follow. 
These are exported to your shell. A script is available to automate setting 
these variables.

The script is sourced while in the condor directory.

```
cd condor
mkdir Downloads
source how-to/env/setupenv.sh
```

Once the script is sourced these variables will exist in your current shell.


- TOP
    - This var points to where all CPM repo's will live. This is essentially /path/to/condor.
    - <b>export TOP=\`pwd\`</b>

- BENCHMARKS
    - Path to the repo containing the CPM benchmarks
    - <b>export CPM_ENV=$TOP/benchmarks</b>

- BUILDROOT
    - The linux file system source used by dromajo to boot linux
    - <b>export BUILDROOT=$TOP/buildroot-2020.05.1</b>

- CPM_ENV
    - A directory with environment scripts and resource files
    - <b>export CPM_ENV=$TOP/how-to/env</b>

- DROMAJO
    - This var points to the dromajo under riscv-perf-model
    - <b>export DROMAJO=$TOP/dromajo</b>

- KERNEL
    - The linux kernel source used for running linux on dromajo.
    - <b>export KERNEL=$TOP/linux-5.8-rc4</b>

- MAP
    - This var points to the Sparcians/Map repo copy
    - <b>export MAP=$TOP/map</b>

- OLYMPIA
    - This var points to the riscv-perf-model (aka Olympia) repo copy
    - <b>export OLYMPIA=$TOP/riscv-perf-model</b>

- OPENSBI
    - This the open supervisor binary interface source used by dromajo
    - <b>export OPENSBI=$TOP/opensbi</b>

- PATCHES
    - A directory with pre-modified source files and patch files
    - <b>export PATCHES=$TOP/how-to/patches</b>

- RV_BAREMETAL_TOOLS
    - This var points to the gnu bare metal tool chain install directory.
    - <b>export RV_BAREMETAL_TOOLS=$TOP/riscv64-unknown-elf</b>

- RV_LINUX_TOOLS
    - This var points to the gnu linux tool chain install directory.
    - <b>export RV_LINUX_TOOLS=$TOP/riscv64-unknown-linux-gnu</b>

- RV_TOOLS_SRC
    - This var points to the tool chain source directory
    - <b>export RV_TOOLS_SRC=$TOP/riscv-gnu-toolchain</b>

- WGETTMP
    - Some packages require manual download using wget.
    - This a temporary directory for that purpose.
    - <b>export WGETTMP=/tmp</b>

