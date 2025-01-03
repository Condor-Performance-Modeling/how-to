#!/bin/bash
set -e
# -------------------------------------------------------
# Sym link the cross compilers
# -------------------------------------------------------
if [ ! -L riscv64-unknown-elf ]; then
  ln -sfv /data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1 riscv64-unknown-elf
fi

if [ ! -L riscv64-unknown-linux-gnu ]; then
  ln -sfv /data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1 riscv64-unknown-linux-gnu
fi

# -------------------------------------------------------
# Repos
# -------------------------------------------------------

# benchmarks
if [ ! -d benchmarks ]; then
  git clone --recurse-submodules \
            git@github.com:Condor-Performance-Modeling/benchmarks.git
fi

# Cam
if [ ! -d cam ]; then
  git clone git@github.com:Condor-Performance-Modeling/cam.git
fi

# Tools
if [ ! -d tools ]; then
  git clone git@github.com:Condor-Performance-Modeling/tools.git
fi

# Utils
if [ ! -d utils ]; then
  git clone git@github.com:Condor-Performance-Modeling/utils.git
fi

# Olympia fork
if [ ! -d cpm.riscv-perf-model ]; then
git clone --recurse-submodules \
    git@github.com:Condor-Performance-Modeling/riscv-perf-model.git \
    cpm.riscv-perf-model
fi
# Dromajo fork
if [ ! -d  cpm.dromajo ]; then
  git clone git@github.com:Condor-Performance-Modeling/dromajo cpm.dromajo
fi

# create the tools directories explicitly here, to avoid creating
# files w/ the directory names
mkdir -p ./tools/bin
mkdir -p ./tools/lib
mkdir -p ./tools/include
mkdir -p ./tools/riscv-linux
