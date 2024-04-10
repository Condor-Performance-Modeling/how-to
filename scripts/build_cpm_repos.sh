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
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/cam.git"
}
fi

cd $CAM;

#ignore the error if already patched
git apply $TOP/how-to/patches/scoreboard_patch_map_v2.patch || true

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
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/dromajo.git" "cpm.dromajo"
}
fi

cd $CPM_DROMAJO

ln -sfv ../stf_lib

# The stf version
mkdir -p build; cd build
cmake ..
make -j$(nproc)
cp dromajo $TOOLS/bin/cpm_dromajo

# The stf + simpoint version
cd ..
mkdir -p build-simpoint; cd build-simpoint
cmake .. -DSIMPOINT=On
make -j$(nproc)
cp dromajo $TOOLS/bin/cpm_simpoint_dromajo

# -------------------------------------------------------
# Sym link the cross compilers
# -------------------------------------------------------
if [ ! -L riscv64-unknown-elf ]; then
  ln -sfv /tools/riscv64-unknown-elf
fi

if [ ! -L riscv64-unknown-linux-gnu ]; then
  ln -sfv /tools/riscv64-unknown-linux-gnu
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
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/utils.git"
fi

