# ------------------------------------------------------------------------
# Usage: change to the top directory and source this file
# ------------------------------------------------------------------------
# $TOP is deprecated, eliminated when I get a minute to clean up the
# dependencies
# ------------------------------------------------------------------------
# This var points to where all CPM repo's will live. 
# This is essentially /path/to/condor
unset TOP;        export TOP=`pwd`
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

# This var points to the gnu bare metal tool chain install directory.
unset RV_BAREMETAL_TOOLS; export RV_BAREMETAL_TOOLS=$TOP/riscv64-unknown-elf

# This var points to the gnu linux tool chain install directory.
unset RV_LINUX_TOOLS; export RV_LINUX_TOOLS=$TOP/riscv64-unknown-linux-gnu

# Short cut to Sparcians/Map/Sparta, simplifies build instructions
unset SPARTA; export SPARTA=$TOP/map/sparta

# This var points to riscv-isa-sim aka Spike
unset SPIKE; export SPIKE=$TOP/riscv-isa-sim

# Workspace local tools install directory
unset TOOLS; export TOOLS=$TOP/tools

# This var points to the Veer golden model from chipsalliance/VeeR-ISS
unset VEER; export VEER=$TOP/whisper

# For now this is a duplicate of veer
unset WHISPER; export WHISPER=$TOP/whisper
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
#Unset this, it is handled in the makefiles
unset RISCV; #export RISCV=$TOP/riscv64-unknown-elf
# ------------------------------------------------------------------------
# You could also use $TOP/how-to/downloads if /tmp is not available
# export WGETTMP=$TOP/how-to/downloads
unset WGETTMP; #export WGETTMP=/tmp
# ------------------------------------------------------------------------

