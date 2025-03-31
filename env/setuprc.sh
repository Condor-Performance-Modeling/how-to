# ------------------------------------------------------------------------
# Usage: change to the top directory and source this file
# ------------------------------------------------------------------------
# $TOP is deprecated, eliminated when I get a minute to clean up the
# dependencies
# ------------------------------------------------------------------------
# This var points to where all CPM repo's will live. 
# This is essentially /path/to/condor
unset TOP; export TOP=`pwd`

unset CONDOR_TOP; export CONDOR_TOP=`pwd`

# Path to the repo containing the CPM benchmarks
unset BENCHMARKS; export BENCHMARKS=$TOP/benchmarks

# The linux file system source used by dromajo to boot linux
unset BUILDROOT; export BUILDROOT=$TOP/buildroot-2020.05.1

# A directory containing the Condor Olympia fork
unset CAM; export CAM=$TOP/cam

# This var points to the Condor fork of dromajo 
unset CPM_DROMAJO; export CPM_DROMAJO=$TOP/cpm.dromajo

# Local workspace installed tools
unset CPM_TOOLS; export CPM_TOOLS=$TOP/tools

# Used by the linux build process
unset CROSS_COMPILE; export CROSS_COMPILE=riscv64-unknown-linux-gnu-

# This chipsalliance dromajo version
unset DROMAJO; export DROMAJO=$TOP/dromajo

# The linux kernel source used for running linux on dromajo.
unset KERNEL; export KERNEL=$TOP/linux-5.8-rc4

# This var points to the Sparcians/Map repo copy
unset MAP; export MAP=$TOP/map

# This var points to the riscv-perf-model (aka Olympia) repo copy
unset OLYMPIA; export OLYMPIA=$TOP/riscv-perf-model

# This the open supervisor binary interface source used by dromajo
unset OPENSBI; export OPENSBI=$TOP/opensbi

# A directory with pre-modified source files and patch files
unset PATCHES; export PATCHES=$TOP/how-to/patches

# Used by the baremetal build process
unset RISCV_PREFIX; export RISCV_PREFIX=riscv64-unknown-elf-

## DEPRECATED: This var points to the gnu bare metal tool chain install directory.
#unset RV_BAREMETAL_TOOLS; export RV_BAREMETAL_TOOLS=$TOP/riscv64-unknown-elf
#
## DEPRECATED: This var points to the gnu linux tool chain install directory.
#unset RV_LINUX_TOOLS; export RV_LINUX_TOOLS=$TOP/riscv64-unknown-linux-gnu

# This var points to the gnu bare metal tool chain install directory.
unset RV_GNU_BAREMETAL_TOOLS; export RV_GNU_BAREMETAL_TOOLS=/data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1
unset RISCV; export RISCV=$RV_GNU_BAREMETAL_TOOLS

# This var points to the gnu linux tool chain install directory.
unset RV_GNU_LINUX_TOOLS; export RV_GNU_LINUX_TOOLS=/data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1
unset RISCV_LINUX; export RISCV_LINUX=$RV_GNU_LINUX_TOOLS

# This var points to the llvm bare metal install directory.
unset RV_LLVM_BAREMETAL_TOOLS; export RV_LLVM_BAREMETAL_TOOLS=/data/tools/riscv64-llvm-baremetal

# This var points to the llvm linux install directory.
unset RV_LLVM_LINUX_TOOLS; export RV_LLVM_LINUX_TOOLS=/data/tools/riscv64-llvm-linux

# This var points to the gnu bare metal tool chain install directory.
unset RV_ANDES_GNU_BAREMETAL_TOOLS; export RV_ANDES_GNU_BAREMETAL_TOOLS=/data/tools/AndeSight_STD_V540/toolchains/nds64le-elf-newlib-v5f

# This var points to the gnu linux tool chain install directory.
unset RV_ANDES_GNU_LINUX_TOOLS; export RV_ANDES_GNU_LINUX_TOOLS=/data/tools/AndeSight_STD_V540/toolchains/nds64le-linux-glibc-v5d

# Short cut to Sparcians/Map/Sparta, simplifies build instructions
unset SPARTA; export SPARTA=$TOP/map/sparta

# This var points to riscv-isa-sim aka Spike
unset SPIKE; export SPIKE=$TOP/riscv-isa-sim
unset CPM_SPIKE_DIR; export CPM_SPIKE_DIR=$TOP/cpm.riscv-isa-sim
unset CPM_SPIKE_ANDES_DIR; export CPM_SPIKE_ANDES_DIR=$TOP/cpm.andes.riscv-isa-sim

# Workspace local tools install directory
unset TOOLS; export TOOLS=$TOP/tools

unset WHISPER_DIR; export WHISPER_DIR=$TOP/tenstorrent.whisper

# UTILS is becoming more important
unset UTILS; export UTILS=$TOP/utils
# ------------------------------------------------------------------------
# ------------------------------------------------------------------------
# This path is only valid in C-AWS
unset TRACELIB; export TRACELIB=/data/tracelib
# ------------------------------------------------------------------------
# Previous or deprecated settings
#
# RISCV is eliminated
# CPM_ENV is deprecated, etc
# WGETTMP is eliminated
# RV_TOOLS_SRC is eliminated
# ------------------------------------------------------------------------
unset CPM_ENV; #deprecated export CPM_ENV=$TOP/how-to/env
# ------------------------------------------------------------------------
unset RV_TOOLS_SRC; #deprecated export RV_TOOLS_SRC=$TOP/riscv-gnu-toolchain
# ------------------------------------------------------------------------
# You could also use $TOP/how-to/downloads if /tmp is not available
# export WGETTMP=$TOP/how-to/downloads
unset WGETTMP; #export WGETTMP=/tmp
# ------------------------------------------------------------------------
# This is not done by default, it is here for reference
#export PATH=$RV_BAREMETAL_TOOLS/bin:$RV_LINUX_TOOLS/bin:$PATH

