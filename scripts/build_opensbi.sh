#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

cd $CONDOR_TOP
mkdir -p $TOOLS/riscv-linux

git clone https://github.com/riscv/opensbi.git

cd $OPENSBI
make PLATFORM=generic -j8
cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin $TOOLS/riscv-linux

