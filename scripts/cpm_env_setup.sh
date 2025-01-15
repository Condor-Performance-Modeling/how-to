#!/bin/bash

set -e

#Contact: Stan Iwan
#         Sofomo
#         2024.03.01

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_cpm_env_setup.log"

set_up_cpm_environment() {

    if [[ -z "$TOP" ]] || [[ -z "$RV_LINUX_TOOLS" ]] || [[ -z "$CPM_DROMAJO" ]] || [[ -z "$TOOLS" ]] || [[ -z "$PATCHES" ]]; then
        echo "One or more required environment variables (TOP, RV_LINUX_TOOLS, CPM_DROMAJO, TOOLS, PATCHES) are not set."
        echo "To set the required environment variables, cd into your work area and run: source how-to/env/setuprc.sh"
        exit 1
    fi

    if [[ "$CONDA_DEFAULT_ENV" != "sparta" ]]; then
        echo "The 'sparta' environment is not active. Please activate it before continuing."
        echo "To activate the 'conda' environment, run: conda activate"
        echo "To activate the 'sparta' environment, run: conda activate sparta"
        exit 1
    fi

    PROGRESS_FILE="$TOP/.onboarding_env_setup_progress"

    update_progress() {
        echo "$1" >> "$PROGRESS_FILE"
    }

    check_progress() {
        if [[ -f "$PROGRESS_FILE" ]]; then
            grep -Fxq "$1" "$PROGRESS_FILE"
            return $?
        fi
        return 1
    }

    echo_stage() {
        echo "Starting Script Stage: $1"
    }

    pretty_error() {
        echo
        echo -e "\t# -------------------------------------------------"
        echo -e "\t# $1"
        echo -e "\t# -------------------------------------------------"
        echo
    }

    if check_progress "env_setup_completed"; then
        echo "Previous setup process was completed. Clearing progress file to start fresh."
        rm -f "$PROGRESS_FILE"
    fi

    # Building Sparcians components
    if ! check_progress "build_sparcians"; then
        echo_stage "Building Sparcians components"
        conda install yaml-cpp -y
        cd $TOP
        set +e
        bash how-to/scripts/build_sparcians.sh
        set -e
        if [ $? -ne 0 ]; then
            pretty_error "Failed to build Sparcians components. Please check the errors above or refer to the log file: $LOG_FILE"
            exit 1
        fi
        update_progress "build_sparcians"
    fi

    # Link the cross compilers and check /tools directory
    if ! check_progress "cross_compilers_and_tools_checked"; then
        echo_stage "Checking /data/tools for necessary directories and linking cross compilers"

        if [ ! -d "/data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1" ]; then
            pretty_error "The required directory /data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1 is missing. Please ensure it exists before continuing."
            exit 1
        fi

        if [ ! -d "/data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1" ]; then
            pretty_error "The required directory /data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1 is missing. Please ensure it exists before continuing."
            exit 1
        fi

        cd $TOP
        ln -fs /data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1 riscv64-unknown-elf
        ln -fs /data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1 riscv64-unknown-linux-gnu
        
        set +e
        export PATH=$RV_LINUX_TOOLS/bin:$PATH
        set -e
        if [ $? -ne 0 ]; then
            echo "Failed to update PATH with $RV_LINUX_TOOLS"
            exit 1
        fi
        export CROSS_COMPILE=riscv64-unknown-linux-gnu-

        update_progress "cross_compilers_and_tools_checked"
    fi

    # Build the Linux collateral
    if ! check_progress "linux_collateral_built"; then
        echo_stage "Building the Linux collateral"
        cd $TOP
        set +e
        bash how-to/scripts/build_linux_collateral.sh
        set -e
        if [ $? -ne 0 ]; then
            pretty_error "Failed to build the Linux collateral. Please check the errors above or refer to the log file: $LOG_FILE"
            exit 1
        fi
        update_progress "linux_collateral_built"
    fi

    # Install the CPM Repos
    if ! check_progress "cpm_repos_installed"; then
        echo_stage "Building and Installing the CPM Repos"
        cd $TOP
        set +e
        bash how-to/scripts/build_cpm_repos.sh
        set -e
        if [ $? -ne 0 ]; then
            pretty_error "Failed to install CPM repos. Please check the errors above or refer to the log file: $LOG_FILE"
            exit 1
        fi
        update_progress "cpm_repos_installed"
    fi

    update_progress "env_setup_completed"

    echo "CPM environment setup process completed successfully."
    echo "Please continue with the README section: Boot Linux on CPM Dromajo."
}

set_up_cpm_environment "$@" 2>&1 | tee -a "$LOG_FILE"
