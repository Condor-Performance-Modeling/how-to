#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_cmp_env_setup.log"
CURRENT_STEP=""
COPY_BAREMETAL_TOOLCHAIN=false
COPY_LINUX_TOOLCHAIN=false

echo_step() {
    echo
    echo "Starting Step: $1"
    echo
}

pretty_error() {
    echo
    echo -e "\t#### -------------------------------------------------"
    echo -e "\t#### $1"
    echo -e "\t#### -------------------------------------------------"
    echo
}

exit_gracefully() {
    trap - EXIT
    
    if [[ -n $CURRENT_STEP ]]; then
        pretty_error "An error occurred during $CURRENT_STEP step."
    else
        pretty_error "An unexpected error occurred."
    fi

    exit 1
}

#--------------------------------------------------------------------------------------------------------------------------

get_user_input() {
    echo_step "Environment Setup"

    # Check if Conda environment is active
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        pretty_error "Conda environment is active. Please deactivate Conda and/or Sparta before continuing."
        exit 1
    fi

    # Ask for install path
    echo_step  "Install Path Setup"

    # Ask for the baremetal install path
    echo
    read -p "Enter the baremetal install path [default is $(pwd)/llvm-baremetal]: " BAREMETAL_INSTALL_PATH
    BAREMETAL_INSTALL_PATH=${BAREMETAL_INSTALL_PATH:-$(pwd)/llvm-baremetal}

    # Check if the baremetal install path already contains LLVM directories
    if [ -d "$BAREMETAL_INSTALL_PATH" ] && [ "$(ls -A "$BAREMETAL_INSTALL_PATH")" ]; then
        pretty_error "Baremetal install path already contains LLVM directories."
        exit 1
    fi

    # Ask for the Linux install path
    echo
    read -p "Enter the Linux install path [default is $(pwd)/llvm-linux]: " LINUX_INSTALL_PATH
    LINUX_INSTALL_PATH=${LINUX_INSTALL_PATH:-$(pwd)/llvm-linux}

    # Check if the Linux install path already contains LLVM directories
    if [ -d "$LINUX_INSTALL_PATH" ] && [ "$(ls -A "$LINUX_INSTALL_PATH")" ]; then
        pretty_error "Linux install path already contains LLVM directories."
        exit 1
    fi

    # Confirm installation paths with the user
    echo "LLVM Baremetal will be installed at: $BAREMETAL_INSTALL_PATH"
    echo "LLVM Linux will be installed at: $LINUX_INSTALL_PATH"
    echo
    read -p "Do you wish to continue with these paths? [Y/n]: " confirm_paths
    if [[ ! "$confirm_paths" =~ ^([yY][eE][sS]|[yY])$ ]] && [ -n "$confirm_paths" ]; then
        pretty_error "User aborted the LLVM setup process."
        exit 1
    fi

    # Create directories
    echo "Creating LLVM directories..."
    mkdir -p "$BAREMETAL_INSTALL_PATH" || { pretty_error "Failed to create the baremetal directory at $BAREMETAL_INSTALL_PATH."; exit 1; }
    mkdir -p "$LINUX_INSTALL_PATH" || { pretty_error "Failed to create the Linux directory at $LINUX_INSTALL_PATH."; exit 1; }

    # Ask for source path
    echo_step  "Source Path Setup"
    echo
    read -p "Enter the source directory path [default is $(pwd)]: " SOURCE_DIR
    SOURCE_DIR=${SOURCE_DIR:-$(pwd)}

    if [[ ! -d "$SOURCE_DIR" ]]; then
        echo "Source directory does not exist, creating it..."
        mkdir -p "$SOURCE_DIR" || { pretty_error "Failed to create the source directory at $SOURCE_DIR."; exit 1; }
    fi
    
    echo "Sources will be cloned into: $SOURCE_DIR"

    # Check for pre-built RISC-V GNU Toolchain for Baremetal
    if [ -d "/data/tools/riscv64-unknown-elf" ]; then
        echo
        echo "Found pre-built RISC-V GNU Toolchain for Baremetal."
        echo "Please ensure that the existing toolchain was built using --with-cmodel=medany."
        read -p "Do you want to use the pre-built toolchain? [Y/n]: " use_prebuilt_baremetal
        if [[ "$use_prebuilt_baremetal" =~ ^([yY][eE][sS]|[yY])$ ]] || [ -z "$use_prebuilt_baremetal" ]; then
            COPY_BAREMETAL_TOOLCHAIN=true
        fi
    fi

    # Check for pre-built RISC-V GNU Toolchain for Linux
    if [ -d "/data/tools/riscv64-unknown-linux-gnu" ]; then
        echo
        echo "Found pre-built RISC-V GNU Toolchain for Linux."
        echo "Please ensure that the existing toolchain was built using --with-cmodel=medany."
        read -p "Do you want to use the pre-built toolchain? [Y/n]: " use_prebuilt_linux
        if [[ "$use_prebuilt_linux" =~ ^([yY][eE][sS]|[yY])$ ]] || [ -z "$use_prebuilt_linux" ]; then
            COPY_LINUX_TOOLCHAIN=true
        fi
    fi

    # Confirm start of LLVM setup process
    echo_step "LLVM Setup Process"
    echo
    read -p "The LLVM setup process might take some time. Do you wish to start the process? [Y/n]: " start_setup
    if [[ ! "$start_setup" =~ ^([yY][eE][sS]|[yY])$ ]] && [ -n "$start_setup" ]; then
        pretty_error "User aborted the LLVM setup process."
        exit 1
    fi
}

#--------------------------------------------------------------------------------------------------------------------------

# Function to clone the required repositories
clone_repositories() {
    echo_step "Cloning repositories"

    cd "$SOURCE_DIR" || { echo "Failed to change directory to SOURCE_DIR."; exit 1; }

    # Skip cloning riscv-gnu-toolchain if both toolchains are to be copied
    if ! { [ "$COPY_BAREMETAL_TOOLCHAIN" = true ] && [ "$COPY_LINUX_TOOLCHAIN" = true ]; }; then
        if [ -d "riscv-gnu-toolchain" ]; then
            echo "RISC-V GNU Toolchain directory already exists. Skipping cloning."
        else
            echo "Cloning RISC-V GNU Toolchain..."
            git clone --recursive https://github.com/riscv/riscv-gnu-toolchain || { echo "Failed to clone RISC-V GNU Toolchain."; exit 1; }
        fi
    else
        echo "Skipping cloning RISC-V GNU Toolchain because pre-built toolchains for both Baremetal and Linux will be used."
    fi

    if [ -d "riscv-llvm" ]; then
        echo "LLVM project directory already exists. Skipping cloning."
    else
        echo "Cloning LLVM project..."
        git clone https://github.com/llvm/llvm-project.git riscv-llvm || { echo "Failed to clone LLVM project."; exit 1; }
    fi

    # Create the symbolic link and fail if the operation does not succeed
    if [ ! -d "riscv-llvm/llvm/tools/clang" ]; then
        cd riscv-llvm || { echo "Failed to enter riscv-llvm directory."; exit 1; }
        ln -s ../../clang llvm/tools || { echo "Failed to create symbolic link for clang."; exit 1; }
    else
        echo "Symbolic link for clang already exists."
    fi
}

# Function to copy or compile the RISC-V GNU Toolchain for Baremetal
compile_or_copy_riscv_gnu_toolchain_baremetal() {
    echo_step "Setting up RISC-V GNU Toolchain for Baremetal"

    if [ "$COPY_BAREMETAL_TOOLCHAIN" = true ]; then
        echo "Copying the RISC-V GNU Toolchain for Baremetal..."
        cp -fa /data/tools/riscv64-unknown-elf/* "$BAREMETAL_INSTALL_PATH/" || { echo "Failed to copy the RISC-V GNU Toolchain for Baremetal."; exit 1; }
    else
        echo "Compiling RISC-V GNU Toolchain for Baremetal from source..."
        cd "$SOURCE_DIR/riscv-gnu-toolchain" || { echo "Failed to change directory to riscv-gnu-toolchain."; exit 1; }
        make clean || echo "make clean failed or not configured. Proceeding without cleaning..."
        ./configure --prefix="$BAREMETAL_INSTALL_PATH" --enable-multilib --with-cmodel=medany || { echo "Failed to configure RISC-V GNU Toolchain for Baremetal."; exit 1; }
        make -j $(nproc) || { echo "Failed to compile RISC-V GNU Toolchain for Baremetal."; exit 1; }
    fi
}

# Function to copy or compile RISC-V GNU Toolchain for Linux
compile_or_copy_riscv_gnu_toolchain_linux() {
    echo_step "Setting up RISC-V GNU Toolchain for Linux"

    if [ "$COPY_LINUX_TOOLCHAIN" = true ]; then
        echo "Copying the RISC-V GNU Toolchain for Linux..."
        cp -fa /data/tools/riscv64-unknown-linux-gnu/* "$LINUX_INSTALL_PATH/" || { echo "Failed to copy the RISC-V GNU Toolchain for Linux."; exit 1; }
    else
        echo "Compiling RISC-V GNU Toolchain for Linux from source..."
        cd "$SOURCE_DIR/riscv-gnu-toolchain" || { echo "Failed to change directory to riscv-gnu-toolchain."; exit 1; }
        make clean || echo "make clean failed or not configured. Proceeding without cleaning..."
        ./configure --prefix="$LINUX_INSTALL_PATH" --with-arch=rv64gc --with-abi=lp64d --enable-linux --enable-multilib --with-cmodel=medany || { echo "Failed to configure RISC-V GNU Toolchain for Linux."; exit 1; }
        make linux -j $(nproc) || { echo "Failed to compile RISC-V GNU Toolchain for Linux."; exit 1; }
    fi
}

# Function to compile LLVM for Baremetal
compile_llvm_baremetal() {
    echo_step "Compiling LLVM for Baremetal"

    cd "$SOURCE_DIR/riscv-llvm" || { echo "Failed to change directory to riscv-llvm."; exit 1; }
    rm -rf _build || { echo "Failed to remove previous build directory."; exit 1; }
    mkdir _build || { echo "Failed to create build directory."; exit 1; }
    cd _build || { echo "Failed to change directory to build directory."; exit 1; }
    cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
      -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
      -DCMAKE_INSTALL_PREFIX="$BAREMETAL_INSTALL_PATH" \
      -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False \
      -DDEFAULT_SYSROOT="$BAREMETAL_INSTALL_PATH/riscv64-unknown-elf" \
      -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-elf" \
      -DLLVM_TARGETS_TO_BUILD="RISCV" \
      -DLLVM_ENABLE_PROJECTS="bolt;clang;clang-tools-extra;libclc;lld;lldb;mlir;openmp;polly;pstl" \
      ../llvm || { echo "Failed to configure LLVM for Baremetal."; exit 1; }
    cmake --build . --target install || { echo "Failed to build LLVM for Baremetal."; exit 1; }
}

# Function to compile LLVM for Linux
compile_llvm_linux() {
    echo_step "Compiling LLVM for Linux"

    cd "$SOURCE_DIR/riscv-llvm" || { echo "Failed to change directory to riscv-llvm."; exit 1; }
    rm -rf _build || { echo "Failed to remove previous build directory."; exit 1; }
    mkdir _build || { echo "Failed to create build directory."; exit 1; }
    cd _build || { echo "Failed to change directory to build directory."; exit 1; }
    
    cmake -G Ninja -DCMAKE_BUILD_TYPE="Release" \
          -DBUILD_SHARED_LIBS=True -DLLVM_USE_SPLIT_DWARF=True \
          -DCMAKE_INSTALL_PREFIX="$LINUX_INSTALL_PATH" \
          -DLLVM_OPTIMIZED_TABLEGEN=True -DLLVM_BUILD_TESTS=False \
          -DDEFAULT_SYSROOT="$LINUX_INSTALL_PATH/sysroot" \
          -DLLVM_DEFAULT_TARGET_TRIPLE="riscv64-unknown-linux-gnu" \
          -DLLVM_TARGETS_TO_BUILD="RISCV" \
          -DLLVM_ENABLE_PROJECTS="bolt;clang;clang-tools-extra;libclc;lld;lldb;mlir;openmp;polly;pstl" \
          ../llvm || { echo "Failed to configure LLVM for Linux."; exit 1; }
          
    cmake --build . --target install || { echo "Failed to build LLVM for Linux."; exit 1; }
}

#--------------------------------------------------------------------------------------------------------------------------

build_llvm() {
    get_user_input

    trap exit_gracefully EXIT

    clone_repositories
    compile_or_copy_riscv_gnu_toolchain_baremetal
    compile_llvm_baremetal
    compile_or_copy_riscv_gnu_toolchain_linux
    compile_llvm_linux

    trap - EXIT
    
    echo "LLVM setup for Baremetal and Linux has been completed."
    echo "LLVM for Baremetal installed at: $BAREMETAL_INSTALL_PATH"
    echo "LLVM for Linux installed at: $LINUX_INSTALL_PATH"
}

build_llvm "$@" 2>&1 | tee -a "$LOG_FILE"
