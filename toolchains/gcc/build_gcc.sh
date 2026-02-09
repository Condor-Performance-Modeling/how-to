#!/bin/bash

#Contact: Stan Iwan
#         Sofomo
#         2024.09.16

# Conditionally source sha.config if it exists in the script's directory
if [ -f "$(dirname "$0")/sha.config" ]; then
    source "$(dirname "$0")/sha.config"
else
    echo "sha.config not found. Skipping..."
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_build_gcc.log"
START_TIME=$(date +%s)
TOTAL_START_TIME=$(date +%s)

log_step() {
    local message="$1"
    echo -e "[$(date)] - Step: $message" | tee -a "$LOG_FILE"
}

complete_step() {
    local message="$1"
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    echo -e "[$(date)] - Completed: $message - Duration: ${duration}s" | tee -a "$LOG_FILE"
    START_TIME=$(date +%s)
}

pretty_error() {
    echo
    echo -e "\t#### -------------------------------------------------"
    echo -e "\t#### ERROR: $1"
    echo -e "\t#### -------------------------------------------------" | tee -a "$LOG_FILE"
    echo
    exit 1
}

# Check prerequisites (git, make, gcc, etc.)
check_prerequisites() {
    log_step "Checking prerequisites"
    
    command -v git >/dev/null 2>&1 || pretty_error "git is required but not installed."
    command -v make >/dev/null 2>&1 || pretty_error "make is required but not installed."
    command -v gcc >/dev/null 2>&1 || pretty_error "gcc is required but not installed."
    
    complete_step "Checked prerequisites"
}

get_user_input() {
    log_step "Install Path Setup"

    echo "Enter the source directory where the repository should be cloned (default is $(pwd)/riscv-gnu-toolchain):"
    read -r SOURCE_DIR
    SOURCE_DIR=${SOURCE_DIR:-$(pwd)}

    echo "Enter the installation directory for baremetal (default is $(pwd)/gcc-baremetal):"
    read -r BAREMETAL_INSTALL_PATH
    BAREMETAL_INSTALL_PATH=${BAREMETAL_INSTALL_PATH:-$(pwd)/gcc-baremetal}

    echo "Enter the installation directory for Linux (default is $(pwd)/gcc-linux):"
    read -r LINUX_INSTALL_PATH
    LINUX_INSTALL_PATH=${LINUX_INSTALL_PATH:-$(pwd)/gcc-linux}

    echo "Enter the installation directory for Linux with vector mstdlibs (default is $(pwd)/gcc-linux-vector-stdlib):"
    read -r LINUX_INSTALL_PATH_VECTOR
    LINUX_INSTALL_PATH_VECTOR=${LINUX_INSTALL_PATH_VECTOR:-$(pwd)/gcc-linux}

    echo "Source Directory: $SOURCE_DIR/riscv-gnu-toolchain"
    echo "Baremetal Install Path: $BAREMETAL_INSTALL_PATH"
    echo "Linux Install Path: $LINUX_INSTALL_PATH"
    echo "Linux with vector stdlib Install Path: $LINUX_INSTALL_PATH_VECTOR"
    echo

    complete_step "Install Path Setup"
}

confirm_proceed() {
    echo
    read -p "Cloning and compiling GCC may take a long time. Do you wish to continue? [y/N]: " proceed
    if [[ ! "$proceed" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        pretty_error "User chose not to proceed. Aborting."
    fi
}

clone_riscv_gcc_toolchain() {
    log_step "Cloning RISC-V GCC Toolchain"
    
    git clone https://github.com/riscv/riscv-gnu-toolchain || pretty_error "Failed to clone RISC-V GNU Toolchain."

    complete_step "Cloning RISC-V GCC Toolchain"
}

checkout_riscv_gcc_toolchain() {
    log_step "Checking out RISC-V GCC Toolchain at: $RISCV_GNU_TOOLCHAIN_COMMIT_SHA"

    cd riscv-gnu-toolchain || pretty_error "Failed to change directory to riscv-gnu-toolchain."
    git fetch || pretty_error "Failed to fetch riscv-gnu-toolchain."
    git checkout "$RISCV_GNU_TOOLCHAIN_COMMIT_SHA" || pretty_error "Failed to checkout specified commit for RISC-V GNU Toolchain."

    complete_step "Checking out RISC-V GCC Toolchain at: $RISCV_GNU_TOOLCHAIN_COMMIT_SHA"
}


verify_repository_clone() {
    log_step "Verifying RISC-V GNU Toolchain clone and commit"

    if [ ! -d "$SOURCE_DIR/riscv-gnu-toolchain" ]; then
        pretty_error "Repository does not exist. Cloning was not successful."
    fi
    
    cd "$SOURCE_DIR/riscv-gnu-toolchain" || pretty_error "Failed to enter riscv-gnu-toolchain directory."
    CURRENT_COMMIT=$(git rev-parse HEAD)
    if [ "$CURRENT_COMMIT" != "$RISCV_GNU_TOOLCHAIN_COMMIT_SHA" ]; then
        pretty_error "Cloned repository is not at the correct commit SHA. Expected: $RISCV_GNU_TOOLCHAIN_COMMIT_SHA, but got: $CURRENT_COMMIT."
    fi

    complete_step "Verified RISC-V GNU Toolchain clone and commit"
}

build_gcc_baremetal() {
    log_step "Building GCC for Baremetal"
    echo "Building GCC for Baremetal in $BAREMETAL_INSTALL_PATH..." | tee -a "$LOG_FILE"
    cd "$SOURCE_DIR/riscv-gnu-toolchain" || pretty_error "Failed to enter riscv-gnu-toolchain directory."

    mkdir -p _build_baremetal
    cd _build_baremetal || pretty_error "Failed to enter riscv-gnu-toolchain/_build_baremetal directory."
    rm -rf ./*
    ../configure \
        --prefix="$BAREMETAL_INSTALL_PATH" \
        --enable-multilib \
        --with-cmodel=medany \
        || pretty_error "Failed to configure GCC for baremetal."
    make -j$(nproc) || pretty_error "Failed to build GCC for baremetal."
    cd ..

    complete_step "Building GCC for Baremetal"
}

build_gcc_linux() {
    log_step "Building GCC for Linux"
    echo "Building GCC for Linux in $LINUX_INSTALL_PATH..." | tee -a "$LOG_FILE"
    cd "$SOURCE_DIR/riscv-gnu-toolchain" || pretty_error "Failed to enter riscv-gnu-toolchain directory."

    mkdir -p _build_linux
    cd _build_linux || pretty_error "Failed to enter riscv-gnu-toolchain/_build_linux directory."
    rm -rf ./*
    ../configure \
        MAKEINFO=true \
        --prefix="$LINUX_INSTALL_PATH" \
        --with-arch=rv64gc \
        --with-abi=lp64d \
        --enable-linux \
        --with-cmodel=medany \
        --enable-multilib \
        --with-multilib-generator="rv64gc-lp64--;rv64gc-lp64d--;rv32gc-ilp32;rv32gc-ilp32d--" \
         || pretty_error "Failed to configure GCC for Linux."
    make linux -j$(nproc) || pretty_error "Failed to build GCC for Linux."
    cd ..

    complete_step "Building GCC for Linux"
}

build_gcc_linux_vector() {
    log_step "Building GCC for Linux"
    echo "Building GCC for Linux in $LINUX_INSTALL_PATH_VECTOR..." | tee -a "$LOG_FILE"
    cd "$SOURCE_DIR/riscv-gnu-toolchain" || pretty_error "Failed to enter riscv-gnu-toolchain directory."

    mkdir -p _build_linux_v
    cd _build_linux_v || pretty_error "Failed to enter riscv-gnu-toolchain/_build_linux_v directory."
    rm -rf ./*
    ../configure \
        MAKEINFO=true \
        --prefix="$LINUX_INSTALL_PATH_VECTOR" \
        --with-arch=rv64gcv \
        --with-abi=lp64d \
        --enable-linux \
        --with-cmodel=medany \
        --enable-multilib \
        --with-multilib-generator="rv64gcv-lp64--;rv64gcv-lp64d--;rv32gcv-ilp32;rv32gcv-ilp32d--" \
         || pretty_error "Failed to configure GCC for Linux with vector stdlibs."
    make linux -j$(nproc) || pretty_error "Failed to build GCC for Linux with vector stdlibs."
    cd ..

    complete_step "Building GCC for Linux with vector stdlibs"
}

build_gcc() {
    trap 'pretty_error "An unexpected error occurred."' ERR

    check_prerequisites
    get_user_input
    confirm_proceed

    cd "$SOURCE_DIR" || pretty_error "Failed to change to source directory $SOURCE_DIR."
    if [ -d "$SOURCE_DIR/riscv-gnu-toolchain" ]; then
        echo "Repository already exists. Verifying..."
        checkout_riscv_gcc_toolchain
        verify_repository_clone
    else
        clone_riscv_gcc_toolchain
        checkout_riscv_gcc_toolchain
        verify_repository_clone
    fi
    
    build_gcc_baremetal
    build_gcc_linux
    build_gcc_linux_vector
    
    local total_end_time=$(date +%s)
    local total_duration=$((total_end_time - TOTAL_START_TIME))
    echo -e "[$(date)] - GCC build process completed - Total Duration: ${total_duration}s" | tee -a "$LOG_FILE"
}

build_gcc "$@" | tee -a "$LOG_FILE"
