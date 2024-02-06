
# Building LLVM on Linux for RISC-V 64-bit Cross-Compilation

This document outlines the steps to build LLVM on a Linux machine for cross-compiling C/C++ code for RISC-V 64-bit.

## Before You Start

Update your package manager to avoid errors during setup:

```bash
sudo apt-get update
# or
sudo apt update
```

## Setup RISC-V and LLVM Environments

Install the required packages:

```bash
sudo apt-get -y install \
  binutils build-essential libtool texinfo \
  gzip zip unzip patchutils curl git \
  make cmake ninja-build automake bison flex gperf \
  grep sed gawk python3 bc \
  zlib1g-dev libexpat1-dev libmpc-dev \
  libglib2.0-dev libfdt-dev libpixman-1-dev
```

## Directory Setup for RISC-V and LLVM Files

Create a directory for RISC-V files:

```bash
cd /data/users/$USER/condor # or your preferred workspace
mkdir llvm
cd llvm
export PATH=/data/tools/bin:$PATH # adjust to your chosen install path
hash -r  # cleans the command hash to ensure the environment is up to date
```

## Cloning and Building the RISC-V GNU Toolchain

Ensure the repository link is live before cloning:

```bash
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
pushd riscv-gnu-toolchain
./configure --prefix=/data/tools --enable-multilib # adjust to your chosen install path
make -j 32
```

*Optionally, build QEMU for emulation. QEMU is a generic and open source machine emulator and virtualizer. It can be useful for emulating the RISC-V architecture, allowing you to test your compiled programs*

```bash
make -j 32 build-qemu
```

Then, return to your directory for RISC-V and LLVM files

```bash
popd
```

## Cloning and Building LLVM for RISC-V

Clone the LLVM project and initiate the build (Ensure the repository link is live before cloning):

```bash
git clone https://github.com/llvm/llvm-project.git riscv-llvm
pushd riscv-llvm
ln -s ../../clang llvm/tools || true
mkdir _build
cd _build
 # adjust DCMAKE_INSTALL_PREFIX to your chosen install path
cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
  -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
  -DCMAKE_INSTALL_PREFIX=/data/tools \
  -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False \
  -DDEFAULT_SYSROOT="../../_install/riscv64-unknown-elf" \
  -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
  -DLLVM_TARGETS_TO_BUILD="RISCV" \
  ../llvm
cmake --build . --target install
popd
```

## Compiling a Simple C/C++ Program for RISC-V 64-bit

Create a source file `hello.c`:

```c
#include <stdio.h>
int main(){
  printf("Hello RISCV!\n");
  return 0;
}
```

The compilation process involves two main steps: compiling the source code into an object file, and then linking the object file to create an executable.

**Compile the code:**

```bash
clang -O -c hello.c
riscv64-unknown-elf-gcc hello.o -o hello -march=rv64imac -mabi=lp64
```

Note on `-march` and `-mabi`: These flags specify the architecture and ABI, respectively. They must be compatible with your RISC-V target.

`-march` - This flag specifies the RISC-V architecture variant. The value `rv64imac` means the target is a 64-bit RISC-V processor supporting a specific set of instruction extensions:
- `I` for integer instructions
- `M` for integer multiplication and division
- `A` for atomic instructions
- `C` for compressed instructions, which allow for smaller code size

`-mabi` - This flag specifies the ABI, defining how functions call each other and how data is accessed in memory. `lp64` means "long and pointers are 64 bits," aligning with the 64-bit architecture. The ABI must match the processor and OS conventions to ensure correct operation.

*Optionally, test your program with QEMU (if available):*

```bash
qemu-riscv64 hello
```
