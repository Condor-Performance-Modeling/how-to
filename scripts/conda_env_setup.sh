#!/bin/bash

# Contact: Stan Iwan
#          Sofomo
#          2024.04.09

set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${TIMESTAMP}_conda_env_setup.log"

if [[ -z "$TOP" ]] || [[ -z "$MAP" ]]; then
    echo "One or more required environment variables (TOP, MAP) are not set."
    echo "To set the required environment variables, cd into your work area and run: source how-to/env/setuprc.sh"
    exit 1
fi

source "$TOP/how-to/scripts/git_clone_retry.sh"

if [[ -z "$CONDA_DEFAULT_ENV" ]]; then
    echo "No Conda environment is currently active. Please activate the 'base' environment before continuing."
    echo "To activate the 'base' environment, run: conda activate"
    exit 1
elif [[ "$CONDA_DEFAULT_ENV" == "sparta" ]]; then
    echo "The 'sparta' environment is currently active. Please deactivate it and activate the 'base' environment before continuing."
    echo "To deactivate the current environment and activate the 'base' environment, run: conda deactivate"
    exit 1
elif [[ "$CONDA_DEFAULT_ENV" != "base" ]]; then
    echo "The Conda environment '$CONDA_DEFAULT_ENV' is active, but the 'base' environment is required. Please activate the 'base' environment before continuing."
    exit 1
fi

set_up_conda_environment() {

    echo "Installing conda-forge packages..."
    conda install -c conda-forge jq yq -y || {
        echo "Failed to install conda-forge packages."
        exit 1
    }

    echo "Cloning the MAP repository..."
    cd "$TOP" || exit 1
    clone_repository_with_retries "https://github.com/sparcians/map.git" || {
        echo "Failed to clone the MAP repository."
        exit 1
    }

    echo "Checking out the map_v2 branch..."
    cd "$MAP" || exit 1
    git checkout map_v2 || {
        echo "Failed to checkout map_v2 branch."
        exit 1
    }

    echo "Creating the Sparta Conda environment..."
    set +e  
    ./scripts/create_conda_env.sh sparta dev
    CONDA_EXIT_CODE=$?
    set -e

    if [[ $CONDA_EXIT_CODE -ne 0 ]]; then
        echo "create_conda_env.sh failed, running fallback command"
        conda env create -f scripts/rendered_safe_environment.yaml || {
            echo "Fallback conda environment creation failed."
            exit 1
        }
    fi

    echo "Setup process completed."
    echo "Please activate the 'sparta' environment by running: conda activate sparta"
}

set_up_conda_environment "$@" 2>&1 | tee -a "$LOG_FILE"

