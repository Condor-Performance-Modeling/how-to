#! /bin/bash
# TODO: THIS IS INCOMPLETE -  finish it ,this is a placeholder
if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

cd $TOP

mkdir -p $TOOLS/riscv-linux

wget --no-check-certificate -nc https://git.kernel.org/torvalds/t/linux-5.8-rc4.tar.gz
tar -xf linux-5.8-rc4.tar.gz
make -C linux-5.8-rc4 ARCH=riscv defconfig
make -C linux-5.8-rc4 ARCH=riscv -j8
mkdir -p $TOOLS/riscv-linux
cp linux-5.8-rc4/arch/riscv/boot/Image $TOOLS/riscv-linux/Image

