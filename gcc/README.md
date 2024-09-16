
# GCC Build Script

This directory includes a script to automate the process of cloning and building the RISC-V GCC toolchain in version 14 for both baremetal and Linux environments.

## Before You Start

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

Before running the script, you need to clone the repository containing build_gcc.sh. This repository also includes additional scripts and documentation that might be useful for your development process.

Clone the repository using SSH:

```bash
git clone git@github.com:Condor-Performance-Modeling/how-to.git
```

## Usage

To begin the setup process, navigate to the directory containing the build_gcc.sh script and execute it. This script automates the tasks of downloading, compiling, and installing the GCC toolchain in version 14 tailored for RISC-V development.

```bash
bash how-to/gcc/build_gcc.sh
```

The script will prompt for:

- The source directory where the repository should be cloned.
- The installation paths for baremetal and Linux GCC.

The script will then proceed to:

- Clone the RISC-V GCC Toolchain repository.
- Checkout the `gcc-14` branch.
- Build GCC for both baremetal and Linux targets.

## Logging

Logs of the build process are stored in a timestamped file (e.g., `20230916_123456_build_gcc.log`).

## Notes

- The script provides options for default values, so user input is optional in most cases.
- The build process may take a significant amount of time depending on your system resources.
