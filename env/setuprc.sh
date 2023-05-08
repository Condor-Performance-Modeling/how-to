
# Change to the top directory and source this file
export TOP=`pwd`
export BENCHMARKS=$TOP/benchmarks
export BUILDROOT=$TOP/buildroot-2020.05.1
export CPM_ENV=$TOP/how-to/env
export DROMAJO=$TOP/dromajo
export KERNEL=$TOP/linux-5.8-rc4
export MAP=$TOP/map
export OLYMPIA=$TOP/riscv-perf-model
export OPENSBI=$TOP/opensbi
export PATCHES=$TOP/how-to/patches
export RV_BAREMETAL_TOOLS=$TOP/riscv64-unknown-elf
export RV_LINUX_TOOLS=$TOP/riscv64-unknown-linux-gnu
export RV_TOOLS_SRC=$TOP/riscv-gnu-toolchain
# You could also use $TOP/how-to/downloads if /tmp is not available
# export WGETTMP=$TOP/how-to/downloads
export WGETTMP=/tmp

export RISCV_PREFIX=riscv64-unknown-elf-
