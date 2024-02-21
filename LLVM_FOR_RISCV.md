
# Building LLVM on Linux for RISC-V 64-bit Cross-Compilation

This document outlines the steps to build LLVM on a Linux machine for cross-compiling C/C++ code for RISC-V 64-bit. 

# Before You Start

*This step is optional. All required packages should already be installed for you. If you want to verify this, follow steps below:*

Update your package manager to avoid errors during setup:

```bash
sudo apt update
```

Install the required packages:

```bash
sudo apt -y install \
  binutils build-essential libtool texinfo \
  gzip zip unzip patchutils curl git \
  make cmake ninja-build automake bison flex gperf \
  grep sed gawk python3 bc \
  zlib1g-dev libexpat1-dev libmpc-dev \
  libglib2.0-dev libfdt-dev libpixman-1-dev
```

## Exit Conda

**You must deactivate the conda environment before building LLVM.**

Deactivate once to exit the sparta environment, once again to exit the base conda
environment.

Your prompt should not show `(base)` or `(sparta)` when you have
successfully deactivated the environments.

```bash
  conda deactivate     # leave sparta
  conda deactivate     # leave base
```

# LLVM for Baremetal

## Directory Setup for Build Files and Installation (Baremetal)

Create a directory for RISC-V files and `_install` directory:

```bash
cd /data/users/$USER/condor # or your preferred workspace
mkdir llvm-baremetal
cd llvm-baremetal
mkdir _install
```

## The RISC-V GNU Toolchain for Baremetal

The `RISC-V GNU toolchain` is necessary to use the LLVM, you should be able to find it under `/data/tools/riscv64-unknown-elf`. Copy it to the `_install` directory in your workspace

```bash
cp -fa /data/tools/riscv64-unknown-elf/* _install/
```

If you don't have the `RISC-V GNU toolchain` ready under `/data/tools/riscv64-unknown-elf`, you can clone and compile it yourself folowing [this section](#cloning-and-building-the-risc-v-gnu-toolchain) instead of copying it.

## Cloning and Building LLVM for RISC-V (Baremetal)

Clone the LLVM project and initiate the build:

```bash
git clone https://github.com/llvm/llvm-project.git riscv-llvm
pushd riscv-llvm
ln -s ../../clang llvm/tools || true
mkdir _build
cd _build
cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
  -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
  -DCMAKE_INSTALL_PREFIX="../../_install" \
  -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False \
  -DDEFAULT_SYSROOT="../../_install/riscv64-unknown-elf" \
  -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
  -DLLVM_TARGETS_TO_BUILD="RISCV" \
  -DLLVM_ENABLE_PROJECTS="clang;lld;lldb" \
  ../llvm
cmake --build . --target install
popd
```

# LLVM for Linux

## Directory Setup for Build Files and Installation (Linux)

Create a directory for RISC-V files and `_install` directory:

```bash
cd /data/users/$USER/condor # or your preferred workspace
mkdir llvm-linux
cd llvm-linux
mkdir _install
```

## The RISC-V GNU Toolchain for Linux

The `RISC-V GNU toolchain` is necessary to use the LLVM, you should be able to find it under `/data/tools/riscv64-unknown-linux-gnu`. Copy it to the `_install` directory in your workspace

```bash
cp -fa /data/tools/riscv64-unknown-linux-gnu/* _install/
```

## Cloning and Building LLVM for RISC-V (Linux)

Clone the LLVM project and initiate the build:

```bash
git clone https://github.com/llvm/llvm-project.git riscv-llvm
pushd riscv-llvm
ln -s ../../clang llvm/tools || true
mkdir _build
cd _build
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE="Release" \
      -DBUILD_SHARED_LIBS=True \
      -DLLVM_USE_SPLIT_DWARF=True \
      -DCMAKE_INSTALL_PREFIX="../../_install" \
      -DLLVM_OPTIMIZED_TABLEGEN=True \
      -DLLVM_BUILD_TESTS=False \
      -DDEFAULT_SYSROOT="../../_install/sysroot" \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-linux-gnu" \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      -DLLVM_ENABLE_PROJECTS="clang;lld;lldb" \
      ../llvm
cmake --build . --target install
popd
```

# Compiling a Simple C/C++ Program for RISC-V 64-bit

Create a source file `hello.c`:

```c
#include <stdio.h>
int main(){
  printf("Hello RISCV!\n");
  return 0;
}
```

**Compile the code:**

Using baremetal version:
```bash
[PATH_TO_YOUR_LLVM_BAREMETAL_INSTALL]/bin/clang -march=rv64gc -mabi=lp64d hello.c -o hello
```

Using linux version:
```bash
[PATH_TO_YOUR_LLVM_LINUX_INSTALL]/bin/clang --target=riscv64-unknown-linux-gnu -o hello hello.c
```

# Cloning and Building the RISC-V GNU Toolchain

This step compiles the `RISC-V toolchain` for baremetal, which is necessary for the `-DDEFAULT_SYSROOT` setting. If you already have the toolchain files in a different directory, you can skip this step and use that path instead.

```bash
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
pushd riscv-gnu-toolchain
./configure --prefix=`pwd`/../_install --enable-multilib # adjust to your chosen install path
make -j 32
popd
```
