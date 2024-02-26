#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_env_setup.log"

set_up_onboarding_environment() {

    if [[ -z "$TOP" ]] || [[ -z "$RV_LINUX_TOOLS" ]] || [[ -z "$CPM_DROMAJO" ]] || [[ -z "$TOOLS" ]] || [[ -z "$PATCHES" ]]; then
        echo "One or more required environment variables (TOP, RV_LINUX_TOOLS, CPM_DROMAJO, TOOLS, PATCHES) are not set."
        echo "Please set them before continuing."
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
        echo "Starting: $1"
    }

    # Building Sparcians components
    if ! check_progress "build_sparcians"; then
        echo_stage "Building Sparcians components"
        conda install yaml-cpp -y
        cd $TOP
        bash how-to/scripts/build_sparcians.sh
        if [ $? -ne 0 ]; then
            echo "Failed to build Sparcians components. Please check the errors above."
            exit 1
        fi
        update_progress "build_sparcians"
    fi

    # Link the cross compilers and check /tools directory
    if ! check_progress "cross_compilers_and_tools_checked"; then
        echo_stage "Checking /tools for necessary directories and linking cross compilers"

        if [ ! -d "/tools/riscv64-unknown-elf" ] || [ ! -d "/tools/riscv64-unknown-linux-gnu" ]; then
            echo "Required directories in /tools are missing."
            exit 1
        fi

        cd $TOP
        ln -fs /tools/riscv64-unknown-elf riscv64-unknown-elf
        ln -fs /tools/riscv64-unknown-linux-gnu riscv64-unknown-linux-gnu
        export PATH=$RV_LINUX_TOOLS/bin:$PATH
        export CROSS_COMPILE=riscv64-unknown-linux-gnu-

        update_progress "cross_compilers_and_tools_checked"
    fi

    # Build the Linux collateral
    if ! check_progress "linux_collateral_built"; then
        echo_stage "Building the Linux collateral"
        cd $TOP
        bash how-to/scripts/build_linux_collateral.sh
        if [ $? -ne 0 ]; then
            echo "Failed to build the Linux collateral. Please check the errors above."
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
            echo "Failed to install CPM repos. Please check the errors above."
            exit 1
        fi
        update_progress "cpm_repos_installed"
    fi

    # Build and Install Olympia
    if ! check_progress "olympia_built"; then
        echo_stage "Building and Installing Olympia"
        cd $TOP
        bash how-to/scripts/build_olympia.sh    
        if [ $? -ne 0 ]; then
            echo "Failed to build Olympia. Please check the errors above."
            exit 1
        fi
        update_progress "olympia_built"
    fi

    # Boot Linux on CPM Dromajo
    if ! check_progress "linux_booted_on_cpm_dromajo"; then
        echo_stage "Booting Linux on CPM Dromajo"
        cd $TOP
        mkdir -p $CPM_DROMAJO/run
        cp $TOOLS/riscv-linux/* $CPM_DROMAJO/run
        cp $PATCHES/cpm.boot.cfg $CPM_DROMAJO/run

        cd $CPM_DROMAJO/run
        $TOOLS/bin/cpm_dromajo --ctrlc --stf_no_priv_check --stf_trace example.stf cpm.boot.cfg
        if [ $? -ne 0 ]; then
            echo "Failed to boot Linux on CPM Dromajo. Please check the errors above."
            exit 1
        fi
        update_progress "linux_booted_on_cpm_dromajo"
    fi

    echo "Onboarding setup process completed successfully."
    rm -f "$PROGRESS_FILE"

}

set_up_onboarding_environment "$@" 2>&1 | tee -a "$LOG_FILE"
