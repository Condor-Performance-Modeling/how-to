#!/bin/bash

# Define a file to track the progress
PROGRESS_FILE="$HOME/.onboarding_progress"

# Function to update progress
update_progress() {
    echo "$1" > "$PROGRESS_FILE"
}

# Function to check last progress
check_progress() {
    if [[ -f "$PROGRESS_FILE" ]]; then
        LAST_STEP=$(cat "$PROGRESS_FILE")
        if [[ "$LAST_STEP" == "$1" ]]; then
            return 0 # True, step was completed
        fi
    fi
    return 1 # False, step was not completed
}

# Function to echo current stage
echo_stage() {
    echo "Starting: $1"
}

# Load the necessary environment variables
source how-to/env/setuprc.sh

# Install the Sparcians repos
if ! check_progress "sparcians_repos_installed"; then
    echo_stage "Install the Sparcians repos"
    # Your installation commands here...
    update_progress "sparcians_repos_installed"
fi

# Install the MAP Miniconda components
if ! check_progress "map_miniconda_installed"; then
    echo_stage "Install the MAP Miniconda components"
    # Assuming conda is already installed and configured
    cd $TOP || exit
    source how-to/env/setuprc.sh
    conda install -c conda-forge jq yq -y
    update_progress "map_miniconda_installed"
fi

# Create the Sparta Conda environment
if ! check_progress "sparta_env_created"; then
    echo_stage "Create the Sparta Conda environment"
    cd $TOP
    git clone https://github.com/sparcians/map.git
    cd $MAP
    git checkout map_v2
    ./scripts/create_conda_env.sh sparta dev
    conda activate sparta
    conda install yaml-cpp -y
    update_progress "sparta_env_created"
fi

# Building Sparcians components
if ! check_progress "sparcians_components_built"; then
    echo_stage "Building Sparcians components"
    conda activate sparta
    cd $TOP
    bash how-to/scripts/build_sparcians.sh
    update_progress "sparcians_components_built"
fi

# Link the cross compilers
if ! check_progress "cross_compilers_linked"; then
    echo_stage "Link the cross compilers"
    cd $TOP
    ln -s /tools/riscv64-unknown-elf
    ln -s /tools/riscv64-unknown-linux-gnu
    update_progress "cross_compilers_linked"
fi

# PATH check and update
if ! check_progress "path_checked"; then
    echo_stage "PATH check for riscv64-unknown-linux-gnu-gcc"
    if ! which riscv64-unknown-linux-gnu-gcc &> /dev/null; then
        echo "riscv64-unknown-linux-gnu-gcc not found in PATH. Adding..."
        export PATH=$RV_LINUX_TOOLS/bin:$PATH
        echo 'export PATH=$RV_LINUX_TOOLS/bin:$PATH' >> ~/.bashrc
    else
        echo "riscv64-unknown-linux-gnu-gcc found in PATH."
    fi
    update_progress "path_checked"
fi

# Set CROSS_COMPILE manually if necessary
echo_stage "Setting CROSS_COMPILE"
export CROSS_COMPILE=riscv64-unknown-linux-gnu-
echo 'export CROSS_COMPILE=riscv64-unknown-linux-gnu-' >> ~/.bashrc

# Build the Linux collateral
if ! check_progress "linux_collateral_built"; then
    echo_stage "Build the Linux collateral"
    cd $TOP
    bash how-to/scripts/build_linux_collateral.sh
    update_progress "linux_collateral_built"
fi

# Install the CPM Repos
if ! check_progress "cpm_repos_installed"; then
    echo_stage "Install the CPM Repos"
    cd $TOP
    bash how-to/scripts/build_cpm_repos.sh
    if [ $? -ne 0 ]; then
        echo "Failed to install CPM repos. Please check the errors above."
        exit 1
    fi
    update_progress "cpm_repos_installed"
fi

echo "Onboarding setup process completed successfully."

