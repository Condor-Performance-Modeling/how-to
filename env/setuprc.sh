
# Change to the top directory and source this file

# tools is deprecated, eliminated when I get a minute to clean up the
# dependencies

# top is deprecated, etc
unset TOP;        export TOP=`pwd`
unset CONDOR_TOP; export CONDOR_TOP=`pwd`

# RISCV is eliminated
# CPM_ENV is deprecated, etc
# WGETTMP is eliminated
# RV_TOOLS_SRC is eliminated

unset BENCHMARKS; export BENCHMARKS=$TOP/benchmarks
unset BUILDROOT; export BUILDROOT=$TOP/buildroot-2020.05.1
unset CAM; export CAM=$TOP/cam
unset CPM_DROMAJO; export CPM_DROMAJO=$TOP/cpm.dromajo
unset CPM_ENV; #export CPM_ENV=$TOP/how-to/env
unset CPM_TOOLS; export CPM_TOOLS=$TOP/tools
unset CROSS_COMPILE; export CROSS_COMPILE=riscv64-unknown-linux-gnu-
unset DROMAJO; export DROMAJO=$TOP/dromajo
unset KERNEL; export KERNEL=$TOP/linux-5.8-rc4
unset MAP; export MAP=$TOP/map
unset OLYMPIA; export OLYMPIA=$TOP/riscv-perf-model
unset OPENSBI; export OPENSBI=$TOP/opensbi
unset PATCHES; export PATCHES=$TOP/how-to/patches
unset RISCV_PREFIX; export RISCV_PREFIX=riscv64-unknown-elf-
unset RV_BAREMETAL_TOOLS; export RV_BAREMETAL_TOOLS=$TOP/riscv64-unknown-elf
unset RV_LINUX_TOOLS; export RV_LINUX_TOOLS=$TOP/riscv64-unknown-linux-gnu
unset RV_TOOLS_SRC; #export RV_TOOLS_SRC=$TOP/riscv-gnu-toolchain
unset SPARTA; export SPARTA=$TOP/map/sparta
unset SPIKE; export SPIKE=$TOP/riscv-isa-sim
unset TOOLS; export TOOLS=$TOP/tools
unset VEER; export VEER=$TOP/whisper
unset WHISPER; export WHISPER=$TOP/whisper

#Unset this, it is handled in the makefiles
unset RISCV; #export RISCV=$TOP/riscv64-unknown-elf

# You could also use $TOP/how-to/downloads if /tmp is not available
# export WGETTMP=$TOP/how-to/downloads
unset WGETTMP; #export WGETTMP=/tmp
