
# Change to the top directory and source this file
unset TOP; export TOP=`pwd`
unset BENCHMARKS; export BENCHMARKS=$TOP/benchmarks
unset BUILDROOT; export BUILDROOT=$TOP/buildroot-2020.05.1
unset CPM_ENV; export CPM_ENV=$TOP/how-to/env
unset DROMAJO; export DROMAJO=$TOP/dromajo
unset KERNEL; export KERNEL=$TOP/linux-5.8-rc4
unset MAP; export MAP=$TOP/map
unset OLYMPIA; export OLYMPIA=$TOP/riscv-perf-model
unset OPENSBI; export OPENSBI=$TOP/opensbi
unset PATCHES; export PATCHES=$TOP/how-to/patches
unset RV_BAREMETAL_TOOLS; export RV_BAREMETAL_TOOLS=$TOP/riscv64-unknown-elf
unset RV_LINUX_TOOLS; export RV_LINUX_TOOLS=$TOP/riscv64-unknown-linux-gnu
unset RV_TOOLS_SRC; export RV_TOOLS_SRC=$TOP/riscv-gnu-toolchain
unset SPIKE; export SPIKE=$TOP/riscv-isa-sim
unset TOOLS; export TOOLS=$TOP/tools
unset VEER; export VEER=$TOP/whisper
unset WHISPER; export WHISPER=$TOP/whisper
# You could also use $TOP/how-to/downloads if /tmp is not available
# export WGETTMP=$TOP/how-to/downloads
unset WGETTMP; export WGETTMP=/tmp
unset RISCV_PREFIX; export RISCV_PREFIX=riscv64-unknown-elf-
#unset RISCV; export RISCV=$TOP/riscv64-unknown-elf
