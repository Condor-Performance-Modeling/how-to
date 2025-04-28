#! /bin/bash

set -e

if [[ -z "${TOP}" ]]; then
  { echo "-E: TOP is undefined, execute 'source how-to/env/setuprc.sh'"; 
exit 1; }
fi

if ! which riscv64-unknown-elf-gcc > /dev/null; then
  echo "-E: RISC-V cross-compiler riscv64-unknown-elf-gcc was not found in PATH."
  echo "-E: Please ensure it is in your PATH, for example:"
  echo "export PATH=\$RV_ANDES_GNU_BAREMETAL_TOOLS/bin:\$PATH"
  exit 1
fi

source "$TOP/how-to/scripts/git_clone_retry.sh"

cd $TOP
# create the tools directories explicitly here, to avoid creating
# files w/ the directory names
mkdir -p $TOOLS/bin

echo "Building CPM Andes Spike"
if ! [ -d "$CPM_ANDES_SPIKE_DIR" ]; then
{
  echo "-W: $CPM_ANDES_SPIKE_DIR does not exist, cloning repo."
  clone_repository_with_retries "git@github.com:Condor-Performance-Modeling/cpm.andes.riscv-isa-sim.git" $CPM_ANDES_SPIKE_DIR "--recurse-submodules"
}
fi

pushd $CPM_ANDES_SPIKE_DIR
mkdir -p build install; cd build
../configure --prefix=`pwd`/../install
make -j$(nproc) 
make install
make regress
popd
