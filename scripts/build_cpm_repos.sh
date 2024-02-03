#! /bin/bash

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

if ! [ -d "$CAM" ]; then
{
  echo "-W: cam does not exist, cloning repo."
  git clone git@github.com:Condor-Performance-Modeling/cam.git
}
fi

if ! [ "$CONDA_DEFAULT_ENV" == "sparta" ]; then
{
  echo "-E: sparta environment is not enabled";
  echo "-E: issue 'conda active sparta' and retry.";
  exit 1;
}
else
{
  echo "-I: sparta environment detected, proceeding";
}
fi
  
mkdir -p $TOOLS/bin
cd $CAM;

mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j32; cmake --install . --prefix $CONDA_PREFIX

# Adding regress step for sanity
make -j32 regress

# Now handled in CMakeLists.txt
#cp cam $TOOLS/bin/cam

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

# create the tools directories explicitly here, to avoid creating
# files w/ the directory names
mkdir -p ./tools/bin
mkdir -p ./tools/lib
mkdir -p ./tools/include
mkdir -p ./tools/riscv-linux
