#!/bin/bash

if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    echo "Conda environment is active. Please deactivate Conda and/or Sparta before continuing."
    exit 1
fi

if [ -z "$TOP" ] || [ ! -d "$TOP" ]; then
    echo "The TOP variable is not set to a valid directory."
    echo "To set the required environment variables, cd into your work area and run: source how-to/env/setuprc.sh"
    exit 1
fi

read -p "Enter the install path [default is $TOP]: " INSTALL_PATH
INSTALL_PATH=${INSTALL_PATH:-$TOP}

if [ -d "$INSTALL_PATH/llvm" ]; then
    echo "Install path already exists. Exiting."
    exit 1
else
    mkdir -p "$INSTALL_PATH/llvm" || { echo "Failed to create install path. Exiting."; exit 1; }
    mkdir -p "$INSTALL_PATH/llvm/llvm-baremetal" || { echo "Failed to create llvm-baremetal directory. Exiting."; exit 1; }
    mkdir -p "$INSTALL_PATH/llvm/llvm-linux" || { echo "Failed to create llvm-linux directory. Exiting."; exit 1; }
    echo "Using install path: $INSTALL_PATH"
fi

read -p "Enter the source directory path [default is $TOP]: " SOURCE_DIR
SOURCE_DIR=${SOURCE_DIR:-$TOP}

if [ -d "$SOURCE_DIR/llvm_source" ]; then
    echo "Source directory already exists. Exiting."
    exit 1
else
    mkdir -p "$SOURCE_DIR/llvm_source" || { echo "Failed to create source directory. Exiting."; exit 1; }
    echo "Using source directory: $SOURCE_DIR/llvm_source"
fi

cd "$SOURCE_DIR/llvm_source" || exit

if [ ! -d "riscv-gnu-toolchain" ]; then
    echo "Cloning the RISC-V GNU Toolchain..."
    git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
fi

if [ ! -d "llvm-project" ]; then
    echo "Cloning LLVM project..."
    git clone https://github.com/llvm/llvm-project.git riscv-llvm
    cd riscv-llvm || exit
    ln -s ../../clang llvm/tools || true
fi

cd "$INSTALL_PATH/llvm/llvm-baremetal" || exit
echo "Setting up directories for LLVM Baremetal..."
mkdir -p _install

echo "Compiling RISC-V GNU Toolchain for Baremetal..."
cd "$SOURCE_DIR/llvm_source/riscv-gnu-toolchain" || exit
make clean
./configure --prefix="$INSTALL_PATH/llvm/llvm-baremetal/_install" --enable-multilib --with-cmodel=medany
make -j $(nproc)

echo "Compiling LLVM for Baremetal..."
cd "$SOURCE_DIR/llvm_source/riscv-llvm" || exit
rm -rf _build
mkdir _build
cd _build || exit
cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
  -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH/llvm/llvm-baremetal/_install" \
  -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False \
  -DDEFAULT_SYSROOT="$INSTALL_PATH/llvm/llvm-baremetal/_install/riscv64-unknown-elf" \
  -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
  -DLLVM_TARGETS_TO_BUILD="RISCV" \
  -DLLVM_ENABLE_PROJECTS="clang;lld;lldb" \
  ../llvm
cmake --build . --target install

cd "$INSTALL_PATH/llvm/llvm-linux" || exit
echo "Setting up directories for LLVM Linux..."
mkdir -p _install

compile_linux_toolchain=false

if [ -d "/data/tools/riscv64-unknown-linux-gnu" ]; then
    echo "Found pre-built RISC-V GNU Toolchain for Linux."
    read -p "Do you want to use the pre-built toolchain? [Y/n]: " use_prebuilt

    if [[ "$use_prebuilt" =~ ^([yY][eE][sS]|[yY])$ ]] || [ -z "$use_prebuilt" ]; then
        echo "Copying the RISC-V GNU Toolchain for Linux..."
        cp -fa /data/tools/riscv64-unknown-linux-gnu/* _install/
    else
      compile_linux_toolchain=true
    fi
else
    compile_linux_toolchain=true
fi

if [ "$compile_linux_toolchain" = true ]; then
    echo "Compiling RISC-V GNU Toolchain for Linux from source..."
    cd "$SOURCE_DIR/llvm_source/riscv-gnu-toolchain" || exit
    make clean
    ./configure --prefix="$INSTALL_PATH/llvm/llvm-linux/_install" --with-arch=rv64gc --with-abi=lp64d --enable-linux
    make linux -j $(nproc)
fi

echo "Compiling LLVM for Linux..."
cd "$SOURCE_DIR/llvm_source/riscv-llvm" || exit
rm -rf _build
mkdir _build
cd _build || exit
cmake -G Ninja \
      -DCMAKE_BUILD_TYPE="Release" \
      -DBUILD_SHARED_LIBS=True \
      -DLLVM_USE_SPLIT_DWARF=True \
      -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH/llvm/llvm-linux/_install" \
      -DLLVM_OPTIMIZED_TABLEGEN=True \
      -DLLVM_BUILD_TESTS=False \
      -DDEFAULT_SYSROOT="$INSTALL_PATH/llvm/llvm-linux/_install/sysroot" \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-linux-gnu" \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      -DLLVM_ENABLE_PROJECTS="clang;lld;lldb" \
      ../llvm
cmake --build . --target install

echo "LLVM setup for Baremetal and Linux has been completed."
echo "LLVM for Baremetal installed at: $INSTALL_PATH/llvm/llvm-baremetal/_install"
echo "LLVM for Linux installed at: $INSTALL_PATH/llvm/llvm-linux/_install"
