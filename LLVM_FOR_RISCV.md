# Building LLVM on Linux for RISC-V 64-bit Cross-Compilation

```text
Contact: Stan Iwan
         Sofomo
         2024.03.07
```

This document outlines the steps to build LLVM on a Linux machine for cross-compiling C/C++ code for RISC-V 64-bit.

## Before You Start

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

### Exit Conda

**You must deactivate the conda environment before building LLVM.**

Deactivate once to exit the sparta environment, once again to exit the base conda
environment.

Your prompt should not show `(base)` or `(sparta)` when you have
successfully deactivated the environments.

```bash
  conda deactivate     # leave sparta
  conda deactivate     # leave base
```

### Clone the Repository

Before running the script, you need to clone the repository containing build_llvm.sh. This repository also includes additional scripts and documentation that might be useful for your development process.

Clone the repository using SSH:

```bash
git clone git@github.com:Condor-Performance-Modeling/how-to.git
```

## Use script to build LLVM

### Running the Script

To begin the setup process, navigate to the directory containing the build_llvm.sh script and execute it. This script automates the tasks of downloading, compiling, and installing the LLVM toolchain tailored for RISC-V development.

```bash
bash how-to/scripts/build_llvm.sh
```

### What `build_llvm.sh` Script Does

- *Cloning Required Repositories:* The script starts by cloning the necessary repositories, including the RISC-V GNU Toolchain and the LLVM project. These repositories provide the source code needed to compile the toolchain and LLVM specifically for the RISC-V architecture.
- *Copying/Compiling RISC-V GNU Toolchain for Baremetal:* Depending on whether a pre-built toolchain is available, the script may copy an existing toolchain or compile a new one for Baremetal development.
- *Compiling LLVM for Baremetal:* Next, the script compiles LLVM components for baremetal development. LLVM provides a collection of modular and reusable compiler and toolchain technologies.
- *Copying/Compiling RISC-V GNU Toolchain for Linux:* Depending on whether a pre-built toolchain is available, the script may copy an existing toolchain or compile a new one for Linux development.
- *Compiling LLVM for Linux:* Finally, the script compiles LLVM for Linux, enabling the development of applications for RISC-V based Linux systems.

Once the script completes successfully, the LLVM toolchain for both baremetal and Linux RISC-V development will be installed in the specified directories.

## Compiling a Simple C/C++ Program for RISC-V 64-bit

Create a source file `hello.c`:

```c
#include <stdio.h>
int main(){
  printf("Hello RISCV!\n");
  return 0;
}
```

Compile the code:

```bash
[PATH_TO_YOUR_LLVM__INSTALL]/bin/clang -march=rv64gc -mabi=lp64d hello.c -o hello
```

## Building LLVM compiler-rt for RISC-V

The LLVM compiler-rt library includes runtime components like compiler support libraries and sanitizers that are essential for developing and testing your RISC-V applications. Follow the steps below to build and install compiler-rt.

### Prerequisites

Before building compiler-rt, ensure you have completed the previous steps for setting up LLVM on your Linux machine for RISC-V cross-compilation. The LLVM toolchain should be successfully installed, and the necessary development packages should be present on your system.

**This script will install LLVM Compiler RT on top of your existing LLVM installations!**

### Running the compiler-rt Build Script

The `how-to` repository includes the `build_llvm_compiler_rt.sh` script, which simplifies the process of building and installing `compiler-rt` on top of existing LLVM installation.

```bash
bash how-to/scripts/build_llvm_compiler_rt.sh
```

### What `build_llvm_compiler_rt.sh` Script Does

- *Validation of LLVM Installation Paths:* Ensures that the LLVM installations for both baremetal and Linux contain the required binaries (clang, clang++, etc.).
- *Cloning Required Repositories:* If the LLVM source is not already present in the specified directory, the script will clone the LLVM project repository.
- *Building compiler-rt for Baremetal and Linux:* Configures and compiles compiler-rt for both baremetal and Linux targets using the previously installed LLVM toolchain.
- *Installation:* The compiled compiler-rt libraries are installed into the specified LLVM installation directories, making them available for development and compilation tasks.

