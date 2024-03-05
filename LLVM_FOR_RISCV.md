
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

**Running the Script:**

```bash
cd $TOP
bash how-to/scripts/build_llvm.sh
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

**Compile the code:**

Baremetal:

```bash
[PATH_TO_YOUR_LLVM_BAREMETAL_INSTALL]/bin/clang -march=rv64gc -mabi=lp64d hello.c -o hello
```

Linux:

```bash
[PATH_TO_YOUR_LLVM_LINUX_INSTALL]/bin/clang --target=riscv64-unknown-linux-gnu -o hello hello.c
```

