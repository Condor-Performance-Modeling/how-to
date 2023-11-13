#!/bin/bash

# -------------------------------------------------------
# Sym link the cross compilers
# -------------------------------------------------------
if [ ! -L riscv64-unknown-elf ]; then
  ln -s /tools/riscv64-unknown-elf
fi

if [ ! -L riscv64-unknown-linux-gnu ]; then
  ln -s /tools/riscv64-unknown-linux-gnu
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
