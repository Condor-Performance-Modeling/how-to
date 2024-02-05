#! /bin/bash

set -e

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "-E: CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; 
exit 1; }
fi

if [[ -z "${CAM}" ]]; then
{
  echo "-E: CAM is undefined, execute 'source how-to/env/setuprc.sh'"; 
  exit 1;
}
fi

cd $TOP
# create the tools directories explicitly here, to avoid creating
# files w/ the directory names
mkdir -p $TOOLS/bin
mkdir -p $TOOLS/lib
mkdir -p $TOOLS/include
mkdir -p $TOOLS/riscv-linux

# CAM
if ! [ -d "$CAM" ]; then
{
  echo "-W: cam does not exist, cloning repo."
  git clone git@github.com:Condor-Performance-Modeling/cam.git
}
fi

cd $CAM;

#ignore the error if already patched
git apply $TOP/how-to/patches/scoreboard_patch_map_v2.patch || true

mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j32;
cmake --install . --prefix $CONDA_PREFIX

# Adding regress step for sanity
make -j32 regress

# Dromajo fork
cd $TOP

if ! [ -d "cpm.dromajo" ]; then
{
  echo "-W: cpm.dromajo does not exist, cloning repo."
  git clone git@github.com:Condor-Performance-Modeling/dromajo.git cpm.dromajo
}
fi

cd $CPM_DROMAJO

ln -s ../stf_lib

# The stf version
mkdir -p build; cd build
cmake ..
make -j32
cp dromajo $TOOLS/bin/cpm_dromajo

# The stf + simpoint version
cd ..
mkdir -p build-simpoint; cd build-simpoint
cmake .. -DSIMPOINT=On
make -j32
cp dromajo $TOOLS/bin/cpm_simpoint_dromajo

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

cd $TOP

# benchmarks
if [ ! -d benchmarks ]; then
  git clone --recurse-submodules \
            git@github.com:Condor-Performance-Modeling/benchmarks.git
fi

# Tools
if [ ! -d tools ]; then
  git clone git@github.com:Condor-Performance-Modeling/tools.git
fi

# Utils
if [ ! -d utils ]; then
  git clone git@github.com:Condor-Performance-Modeling/utils.git
fi

