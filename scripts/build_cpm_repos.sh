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

source "$TOP/how-to/scripts/git_clone_retry.sh"

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
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/cam.git" "cam" "--recurse-submodules"
}
fi

cd $CAM;
git submodule update --init --recursive

mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc);
cmake --install . --prefix $CONDA_PREFIX

# Adding regress step for sanity
make -j$(nproc) regress

# Dromajo fork
cd $TOP

if ! [ -d "cpm.dromajo" ]; then
{
  echo "-W: cpm.dromajo does not exist, cloning repo."
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/dromajo.git" "cpm.dromajo" "--recurse-submodules"
}
fi

cd $CPM_DROMAJO
git submodule update --init --recursive

# The stf version
mkdir -p build; cd build
cmake ..
make -j$(nproc)
cp dromajo $TOOLS/bin/cpm_dromajo

## TODO there is no error capture here
## Run regression tests
#make -j$(nproc) regress

# TODO this is no need for a simpoint version any longer
## The stf + simpoint version
#cd ..
#mkdir -p build-simpoint; cd build-simpoint
#cmake .. -DSIMPOINT=On
#make -j$(nproc)
#cp dromajo $TOOLS/bin/cpm_simpoint_dromajo

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

cd $TOP

# benchmarks
if [ ! -d "benchmarks" ]; then
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/benchmarks.git" \
  "benchmarks" "--recurse-submodules"
fi

# Tools
if [ ! -d tools ]; then
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/tools.git"
fi

# Utils
if [ ! -d utils ]; then
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/utils.git" "utils" "--recurse-submodules"
fi

cd utils
make -j$(nproc)
