#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

cd $CONDOR_TOP
mkdir -p $TOOLS/riscv-linux

# Double check the links to the cross compilers

if [ ! -L riscv64-unknown-elf ]; then
  ln -sfv /tools/riscv64-unknown-elf
fi

if [ ! -L riscv64-unknown-linux-gnu ]; then
  ln -sfv /tools/riscv64-unknown-linux-gnu
fi

# Build the kernel

wget --no-check-certificate -nc \
        https://git.kernel.org/torvalds/t/linux-5.8-rc4.tar.gz
tar -xf linux-5.8-rc4.tar.gz
make -C linux-5.8-rc4 ARCH=riscv defconfig
make -C linux-5.8-rc4 ARCH=riscv -j32
mkdir -p $TOOLS/riscv-linux
cp linux-5.8-rc4/arch/riscv/boot/Image $TOOLS/riscv-linux/Image

# Build the file system

wget --no-check-certificate \
         https://github.com/buildroot/buildroot/archive/2020.05.1.tar.gz
tar xf 2020.05.1.tar.gz
cp $CONDOR_TOP/how-to/patches/config-buildroot-2020.05.1 buildroot-2020.05.1/.config

# This make will fail, followed by a patch
set +e
make -C buildroot-2020.05.1 -j32
set -e
cp $PATCHES/c-stack.c \
          ./buildroot-2020.05.1/output/build/host-m4-1.4.18/lib/c-stack.c

# This make will also fail, followed by another patch
set +e
make -C buildroot-2020.05.1 -j32
set -e
cp $PATCHES/libfakeroot.c \
          ./buildroot-2020.05.1/output/build/host-fakeroot-1.20.2/libfakeroot.c

# This make should not fail
sudo make -C buildroot-2020.05.1 -j32

if ! [ -f $BUILDROOT/output/images/rootfs.cpio ]; then
  echo "-E: rootfs.cpio build failure"; exit 1;
fi

cp $BUILDROOT/output/images/rootfs.cpio $CONDOR_TOP/tools/riscv-linux

# Build OpenSBI

cd $CONDOR_TOP
if [ ! -d "$CONDOR_TOP/opensbi" ]; then
  git clone https://github.com/riscv/opensbi.git
else
  cd opensbi && git pull
fi
cd $OPENSBI
make PLATFORM=generic -j32
cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin $TOOLS/riscv-linux

