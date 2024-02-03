#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  {
    echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; 
    exit 1;
  }
fi

cd $TOP
mkdir -p $TOOLS/riscv-linux

# Build the kernel
wget --no-check-certificate -nc \
        https://git.kernel.org/torvalds/t/linux-5.8-rc4.tar.gz
tar -xf linux-5.8-rc4.tar.gz
make -C linux-5.8-rc4 ARCH=riscv defconfig
make -C linux-5.8-rc4 ARCH=riscv -j8
mkdir -p $TOOLS/riscv-linux
cp linux-5.8-rc4/arch/riscv/boot/Image $TOOLS/riscv-linux/Image

# Build the file system
wget --no-check-certificate \
         https://github.com/buildroot/buildroot/archive/2020.05.1.tar.gz
tar xf 2020.05.1.tar.gz
cp $TOP/how-to/patches/config-buildroot-2020.05.1 buildroot-2020.05.1/.config

# This make will fail, followed by a patch
make -C buildroot-2020.05.1 -j8
cp $PATCHES/c-stack.c \
          ./buildroot-2020.05.1/output/build/host-m4-1.4.18/lib/c-stack.c

# This make will also fail, followed by another patch
make -C buildroot-2020.05.1 -j8
cp $PATCHES/libfakeroot.c \
          ./buildroot-2020.05.1/output/build/host-fakeroot-1.20.2/libfakeroot.c

# This make should not fail
sudo make -C buildroot-2020.05.1 -j8

if ! [ -f $BUILDROOT/output/images/rootfs.cpio ]; then
  echo "-E: rootfs.cpio build failure"; exit 1;
fi

cp $BUILDROOT/output/images/rootfs.cpio $TOP/tools/riscv-linux
