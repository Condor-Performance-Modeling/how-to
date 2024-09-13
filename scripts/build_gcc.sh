#!/bin/bash

source ./sha.config

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_build_gcc.log"
START_TIME=$(date +%s)
TOTAL_START_TIME=$(date +%s)

log_step() {
    local message="$1"
    echo -e "[`date`] - Step: $message" | tee -a "$LOG_FILE"
}

complete_step() {
    local message="$1"
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    echo -e "[`date`] - Completed: $message - Duration: ${duration}s" | tee -a "$LOG_FILE"
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

get_user_input() {
    log_step "Install Path Setup"

    echo "Enter the source directory where the repository should be cloned (default is $(pwd)):"
    read -r SOURCE_DIR
    SOURCE_DIR=${SOURCE_DIR:-$(pwd)}

    echo "Enter the installation directory for baremetal (default is $(pwd)/gcc-baremetal):"
    read -r BAREMETAL_INSTALL_PATH
    BAREMETAL_INSTALL_PATH=${BAREMETAL_INSTALL_PATH:-$(pwd)/gcc-baremetal}

    echo "Enter the installation directory for Linux (default is $(pwd)/gcc-linux):"
    read -r LINUX_INSTALL_PATH
    LINUX_INSTALL_PATH=${LINUX_INSTALL_PATH:-$(pwd)/gcc-linux}

    echo "Source Directory: $SOURCE_DIR"
    echo "Baremetal Install Path: $BAREMETAL_INSTALL_PATH"
    echo "Linux Install Path: $LINUX_INSTALL_PATH"
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
    
    git clone --recursive https://github.com/riscv/riscv-gnu-toolchain || { echo "Failed to clone RISC-V GNU Toolchain."; exit 1; }

    complete_step "Cloning RISC-V GCC Toolchain"
}

checkout_gcc_branch() {
    log_step "Checking out gcc-14 branch in riscv-gnu-toolchain/gcc"

    cd "$SOURCE_DIR/riscv-gnu-toolchain" || pretty_error "Failed to enter riscv-gnu-toolchain directory."
    cd gcc || pretty_error "Failed to enter gcc subdirectory."

    git fetch --all || pretty_error "Failed to fetch in gcc repository."
    git checkout origin/releases/gcc-14 || pretty_error "Failed to check out gcc-14 branch."

    complete_step "Checked out gcc-14 branch in gcc"
}

build_gcc_baremetal() {
    log_step "Building GCC for Baremetal"
    echo "Building GCC for Baremetal in $BAREMETAL_INSTALL_PATH..." | tee -a "$LOG_FILE"
    cd "$SOURCE_DIR/riscv-gnu-toolchain" || pretty_error "Failed to enter riscv-gnu-toolchain directory."

    ./configure --prefix="$BAREMETAL_INSTALL_PATH" --enable-multilib --with-cmodel=medany || pretty_error "Failed to configure GCC for baremetal."
    make -j$(nproc) || pretty_error "Failed to build GCC for baremetal."

    complete_step "Building GCC for Baremetal"
}

build_gcc_linux() {
    log_step "Building GCC for Linux"
    echo "Building GCC for Linux in $LINUX_INSTALL_PATH..." | tee -a "$LOG_FILE"
    cd "$SOURCE_DIR/riscv-gnu-toolchain" || pretty_error "Failed to enter riscv-gnu-toolchain directory."

    ./configure --prefix="$LINUX_INSTALL_PATH" --with-arch=rv64gc --with-abi=lp64d --enable-linux --enable-multilib || pretty_error "Failed to configure GCC for Linux."
    make linux -j$(nproc) || pretty_error "Failed to build GCC for Linux."

    complete_step "Building GCC for Linux"
}

build_gcc() {
    trap 'pretty_error "An unexpected error occurred."' ERR

    get_user_input
    confirm_proceed

    cd "$SOURCE_DIR" || pretty_error "Failed to change to source directory $SOURCE_DIR."
    clone_riscv_gcc_toolchain
    checkout_gcc_branch
    
    build_gcc_baremetal
    build_gcc_linux
    
    log_step "GCC build process completed"
    complete_step "GCC build process"

    local total_end_time=$(date +%s)
    local total_duration=$((total_end_time - TOTAL_START_TIME))
    echo -e "[`date`] - Total Duration: ${total_duration}s" | tee -a "$LOG_FILE"
}

build_gcc "$@" | tee -a "$LOG_FILE"
