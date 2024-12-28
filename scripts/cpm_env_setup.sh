#!/bin/bash

set -e

#Contact: Stan Iwan
#         Sofomo
#         2024.03.01

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_cpm_env_setup.log"
KEEP_PROGRESS_FILE=false

if [[ "$1" == "--keep-progress-file" ]]; then
    KEEP_PROGRESS_FILE=true
fi

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

    # Building Sparcians components
    if ! check_progress "build_sparcians"; then
        echo_stage "Building Sparcians components"
        conda install yaml-cpp -y
        cd $TOP
        bash how-to/scripts/build_sparcians.sh
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
        
        export PATH=$RV_LINUX_TOOLS/bin:$PATH
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
        bash how-to/scripts/build_linux_collateral.sh
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
        bash how-to/scripts/build_cpm_repos.sh
        if [ $? -ne 0 ]; then
            pretty_error "Failed to install CPM repos. Please check the errors above or refer to the log file: $LOG_FILE"
            exit 1
        fi
        update_progress "cpm_repos_installed"
    fi

: '
    # TODO - move to optional script Build and Install Olympia
    if ! check_progress "olympia_built"; then
        echo_stage "Building and Installing Olympia"
        cd $TOP
        bash how-to/scripts/build_olympia.sh    
        if [ $? -ne 0 ]; then
            pretty_error "Failed to build Olympia. Please check the errors above or refer to the log file: $LOG_FILE"
            exit 1
        fi
        update_progress "olympia_built"
    fi
'

: '
    # Boot Linux on CPM Dromajo
    if ! check_progress "linux_booted_on_cpm_dromajo"; then
        echo_stage "Booting Linux on CPM Dromajo"
        cd $TOP
        mkdir -p $CPM_DROMAJO/run
        cp $TOOLS/riscv-linux/* $CPM_DROMAJO/run
        cp $PATCHES/cpm.boot.cfg $CPM_DROMAJO/run

        cd $CPM_DROMAJO/run
        $TOOLS/bin/cpm_dromajo --ctrlc --stf_essential_mode --stf_priv_modes USHM --stf_trace example.stf cpm.boot.cfg
	if [ $? -ne 0 ]; then
            pretty_error "Failed to boot Linux on CPM Dromajo. Please check the errors above or refer to the log file: $LOG_FILE"
            exit 1
        fi
        update_progress "linux_booted_on_cpm_dromajo"
    fi
'

    echo "CPM environment setup process completed successfully."

#TODO never remove the progress file
#    if ! $KEEP_PROGRESS_FILE; then
#        echo "Removing progress file."
#        rm -f "$PROGRESS_FILE"
#    else
#        echo "Keeping progress file as requested."
#    fi

# This is useless
#    if grep -iq "error" "$LOG_FILE"; then
#        echo "WARNING: There were possible errors during the process. Please check the log file: $LOG_FILE"
#    fi
#
    echo "Please continue with the README section: Boot Linux on CPM Dromajo."

}

# This creates problems like this:
# how-to/scripts/cpm_env_setup.sh: error reading input file: Stale file handle

#set_up_cpm_environment "$@" 2>&1 | tee -a "$LOG_FILE"
