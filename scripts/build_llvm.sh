#!/bin/bash

# Check if Conda/Sparta is deactivated
if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo "Conda environment is active. Please deactivate Conda and/or Sparta before continuing."
    exit 1
fi

# Check if $TOP variable is set to a valid directory
if [ -z "$TOP" ] || [ ! -d "$TOP" ]; then
    echo "The TOP variable is not set to a valid directory."
    exit 1
fi

echo "Using TOP directory: $TOP"

# Setup for LLVM for Baremetal
echo "Setting up LLVM for Baremetal..."
cd "$TOP" || exit
mkdir -p llvm-baremetal/_install
cd llvm-baremetal || exit

# Cloning and Building the RISC-V GNU Toolchain for Baremetal
echo "Cloning the RISC-V GNU Toolchain for Baremetal..."
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain || exit
./configure --prefix="$PWD/../_install" --enable-multilib --with-cmodel=medany
make -j $(nproc)
cd ..

# Cloning and Building LLVM for RISC-V (Baremetal)
echo "Cloning LLVM project for RISC-V Baremetal..."
git clone https://github.com/llvm/llvm-project.git riscv-llvm
cd riscv-llvm || exit
ln -s ../../clang llvm/tools || true
mkdir _build
cd _build || exit
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
cd ../../..

# Setup for LLVM for Linux
echo "Setting up LLVM for Linux..."
mkdir -p llvm-linux/_install
cd llvm-linux || exit

# Assuming the RISC-V GNU Toolchain for Linux is pre-built and available
echo "Copying the RISC-V GNU Toolchain for Linux..."
cp -fa /data/tools/riscv64-unknown-linux-gnu/* _install/

# Cloning and Building LLVM for RISC-V (Linux)
echo "Cloning LLVM project for RISC-V Linux..."
git clone https://github.com/llvm/llvm-project.git riscv-llvm
cd riscv-llvm || exit
ln -s ../../clang llvm/tools || true
mkdir _build
cd _build || exit
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
cd ../..

echo "LLVM setup for Baremetal and Linux has been completed."
