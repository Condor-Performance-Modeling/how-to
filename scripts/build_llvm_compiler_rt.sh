#!/bin/bash

#Contact: Stan Iwan
#         Sofomo
#         2024.03.19

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_build_llvm_compiler_rt.log"
CURRENT_STEP=""
CLONE_LLVM_SOURCE=false

LLVM_PROJECT_COMMIT_SHA="7718ac38a0c23597d7d02f0022eb89afe6d1b35f"

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

validate_llvm_install_path() {
    INSTALL_PATH=$1
    PATH_TYPE=$2

    if [[ ! -f "$INSTALL_PATH/bin/clang" ]]; then
        pretty_error "$PATH_TYPE install path does not contain bin/clang."
        exit 1
    else
        echo "$PATH_TYPE LLVM installation found."
    fi
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

    # Ask and validate the baremetal LLVM installation path
    echo
    read -p "Enter the baremetal LLVM installation path [default is $(pwd)/llvm-baremetal]: " BAREMETAL_INSTALL_PATH
    BAREMETAL_INSTALL_PATH=${BAREMETAL_INSTALL_PATH:-$(pwd)/llvm-baremetal}
    validate_llvm_install_path "$BAREMETAL_INSTALL_PATH" "Baremetal"

    # Ask and validate the Linux LLVM installation path
    echo
    read -p "Enter the Linux LLVM installation path [default is $(pwd)/llvm-linux]: " LINUX_INSTALL_PATH
    LINUX_INSTALL_PATH=${LINUX_INSTALL_PATH:-$(pwd)/llvm-linux}
    validate_llvm_install_path "$LINUX_INSTALL_PATH" "Linux"

    # Ask for source path
    echo_step  "Source Path Setup"
    echo
    read -p "Enter the directory path where LLVM source directory (riscv-llvm) is located [default is $(pwd)]: " SOURCE_DIR
    SOURCE_DIR=${SOURCE_DIR:-$(pwd)}

    # Check if the provided SOURCE_DIR exists
    if [[ -d "$SOURCE_DIR" ]]; then
        # The directory exists; now check if it contains the riscv-llvm directory
        if [[ ! -d "$SOURCE_DIR/riscv-llvm" ]]; then
            echo "The directory does not contain 'riscv-llvm'. LLVM source will be cloned."
            CLONE_LLVM_SOURCE=true
        else
            echo "Found 'riscv-llvm' directory in the specified path."
        fi
    else
        # The directory does not exist, indicate that LLVM source needs to be cloned
        echo "The specified directory does not exist. It will be created, and LLVM source will be cloned into it."
        CLONE_LLVM_SOURCE=true
        mkdir -p "$SOURCE_DIR" || { pretty_error "Failed to create the directory at $SOURCE_DIR."; exit 1; }
    fi

    # Confirm start of LLVM build process
    echo_step "LLVM Compiler RT Build Process"
    echo
    read -p "The LLVM Compiler RT build process is ready to be started. Do you wish to start the process? [Y/n]: " start_setup
    if [[ ! "$start_setup" =~ ^([yY][eE][sS]|[yY])$ ]] && [ -n "$start_setup" ]; then
        pretty_error "User aborted the LLVM Compiler RT build process."
        exit 1
    fi
}

#--------------------------------------------------------------------------------------------------------------------------

# Function to clone the required repositories
clone_repositories() {
    echo_step "Cloning repositories"

    cd "$SOURCE_DIR" || { echo "Failed to change directory to SOURCE_DIR."; exit 1; }

    if [ -d "riscv-llvm" ]; then
        echo "LLVM project directory already exists. Skipping cloning."
    else
        echo "Cloning LLVM project..."
        git clone https://github.com/llvm/llvm-project.git riscv-llvm || { echo "Failed to clone LLVM project."; exit 1; }
        cd riscv-llvm || { echo "Failed to change directory to riscv-llvm."; exit 1; }
        git checkout $LLVM_PROJECT_COMMIT_SHA || { echo "Failed to checkout specified commit for LLVM project."; exit 1; }
        cd "$SOURCE_DIR" || { echo "Failed to return to SOURCE_DIR."; exit 1; }
    fi

    # Create the symbolic link and fail if the operation does not succeed
    if [ ! -d "riscv-llvm/llvm/tools/clang" ]; then
        cd riscv-llvm || { echo "Failed to enter riscv-llvm directory."; exit 1; }
        ln -s ../../clang llvm/tools || { echo "Failed to create symbolic link for clang."; exit 1; }
    else
        echo "Symbolic link for clang already exists."
    fi
}

# Function to compile LLVM Compiler RT for Baremetal
compile_llvm_compiler_rt_baremetal() {
    echo_step "Compiling LLVM Compiler RT for Baremetal"

    cd "$SOURCE_DIR/riscv-llvm";
    rm -rf _build-compiler-rt;
    mkdir _build-compiler-rt;
    cd _build-compiler-rt;

    cmake ../compiler-rt \
          -DLLVM_CMAKE_DIR=$BAREMETAL_INSTALL_PATH/lib/cmake/llvm \
          -DCOMPILER_RT_BAREMETAL_BUILD=ON \
          -DCMAKE_INSTALL_PREFIX=$BAREMETAL_INSTALL_PATH \
          -DCMAKE_C_COMPILER=$BAREMETAL_INSTALL_PATH/bin/clang \
          -DCMAKE_CXX_COMPILER=$BAREMETAL_INSTALL_PATH/bin/clang++ \
          -DCMAKE_ASM_COMPILER=$BAREMETAL_INSTALL_PATH/bin/clang \
          -DCMAKE_C_FLAGS="--target=riscv64-unknown-elf" \
          -DCMAKE_CXX_FLAGS="--target=riscv64-unknown-elf" \
          -DCMAKE_ASM_FLAGS="--target=riscv64-unknown-elf" \
          -DCOMPILER_RT_BAREMETAL_BUILD=ON \
          -G "Unix Makefiles" \
          -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
          -DCOMPILER_RT_BUILD_XRAY=OFF \
          -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
          -DCOMPILER_RT_BUILD_PROFILE=OFF \
          -DCOMPILER_RT_BUILD_MEMPROF=OFF;

    make -j $(nproc) || { echo "Failed to build LLVM Compiler RT for Baremetal."; exit 1; }
    make install || { echo "Failed to install LLVM Compiler RT for Baremetal."; exit 1; }
}


# Function to compile LLVM Compiler RT for Linux
compile_llvm_compiler_rt_linux() {
    echo_step "Compiling LLVM Compiler RT for Linux"

    cd "$SOURCE_DIR/riscv-llvm";
    rm -rf _build-compiler-rt;
    mkdir _build-compiler-rt;
    cd _build-compiler-rt;

    # Note: Adjust the following flags and paths as necessary for your Linux target environment
    cmake ../compiler-rt \
          -DLLVM_CMAKE_DIR=$LINUX_INSTALL_PATH/lib/cmake/llvm \
          -DCMAKE_INSTALL_PREFIX=$LINUX_INSTALL_PATH \
          -DCMAKE_C_COMPILER=$LINUX_INSTALL_PATH/bin/clang \
          -DCMAKE_CXX_COMPILER=$LINUX_INSTALL_PATH/bin/clang++ \
          -DCMAKE_ASM_COMPILER=$LINUX_INSTALL_PATH/bin/clang \
          -DCMAKE_C_FLAGS="--target=riscv64-unknown-linux-gnu" \
          -DCMAKE_CXX_FLAGS="--target=riscv64-unknown-linux-gnu" \
          -DCMAKE_ASM_FLAGS="--target=riscv64-unknown-linux-gnu" \
          -G "Unix Makefiles" \
          -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
          -DCOMPILER_RT_BUILD_XRAY=OFF \
          -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
          -DCOMPILER_RT_BUILD_PROFILE=OFF \
          -DCOMPILER_RT_BUILD_MEMPROF=OFF;

    make -j $(nproc) || { echo "Failed to build LLVM Compiler RT for Linux."; exit 1; }
    make install || { echo "Failed to install LLVM Compiler RT for Linux."; exit 1; }
}

#--------------------------------------------------------------------------------------------------------------------------

build_llvm_compiler_rt() {
    get_user_input

    trap exit_gracefully EXIT

    clone_repositories
    compile_llvm_compiler_rt_baremetal
    compile_llvm_compiler_rt_linux

    trap - EXIT
    
    echo "LLVM Compiler RT build for Baremetal and Linux has been completed."
    echo "LLVM Compiler RT for Baremetal installed at: $BAREMETAL_INSTALL_PATH"
    echo "LLVM Compiler RT for Linux installed at: $LINUX_INSTALL_PATH"
}

build_llvm_compiler_rt "$@" 2>&1 | tee -a "$LOG_FILE"
