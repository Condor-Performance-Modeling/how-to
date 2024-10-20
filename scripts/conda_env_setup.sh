#!/bin/bash

#Contact: Stan Iwan
#         Sofomo
#         2024.04.09

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

echo "Installing conda-forge packages..."
conda install -c conda-forge jq yq -y

echo "Cloning the MAP repository..."
cd $TOP
clone_repository_with_retries "https://github.com/sparcians/map.git"

echo "Checking out the map_v2 branch..."
cd $MAP
git checkout map_v2

echo "Creating the Sparta Conda environment..."
./scripts/create_conda_env.sh sparta dev

if [ $? -ne 0 ]; then
    echo "create_conda_env.sh failed, running fallback command"
    conda env create -f scripts/rendered_safe_environment.yaml
fi

echo "Setup process completed."
echo "Please activate the 'sparta' environment by running: conda activate sparta"

