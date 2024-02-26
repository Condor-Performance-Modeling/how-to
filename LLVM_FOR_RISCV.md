
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

# Use script to build LLVM

**Before Running the Script:**

- Ensure you have set the `TOP` environment variable to your desired workspace directory.
- Confirm that any active `Conda`/`Sparta` environments are deactivated.
- This script assumes the `RISC-V GNU Toolchain` for Linux is already built and available at `/data/tools/riscv64-unknown-linux-gnu`. If this is not the case, you would need to build or adjust this part accordingly.

**Running the Script:**

```bash
cd $TOP
bash how-to/scripts/build_llvm.sh
```

<details>
  <summary>Details: Building LLVM for Baremetal step by step</summary>

## Directory Setup for Build Files and Installation (Baremetal)

Create a directory for RISC-V files and `_install` directory:

```bash
cd /data/users/$USER/condor # or your preferred workspace
mkdir llvm-baremetal
cd llvm-baremetal
mkdir _install
```

## The RISC-V GNU Toolchain for Baremetal

This step compiles the `RISC-V toolchain` for baremetal. It is crucial that you use `--with-cmodel=medany` for this toolchain.

```bash
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
pushd riscv-gnu-toolchain
./configure --prefix=`pwd`/../_install --enable-multilib --with-cmodel=medany
make -j 32
popd
```

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

</details>

<details>
  <summary>Details: Building LLVM for Linux step by step</summary>

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

</details>

## Compiling a Simple C/C++ Program for RISC-V 64-bit

Create a source file `hello.c`:

```c
#include <stdio.h>
int main(){
  printf("Hello RISCV!\n");
  return 0;
}
```

**Compile the code:**

Baremetal:

```bash
[PATH_TO_YOUR_LLVM_BAREMETAL_INSTALL]/bin/clang -march=rv64gc -mabi=lp64d hello.c -o hello
```

Linux:

```bash
[PATH_TO_YOUR_LLVM_LINUX_INSTALL]/bin/clang --target=riscv64-unknown-linux-gnu -o hello hello.c
```
