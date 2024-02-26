#!/bin/bash

if [[ -z "$TOP" ]] || [[ -z "$MAP" ]]; then
    echo "One or more required environment variables (TOP, MAP) are not set."
    echo "Please set them before continuing."
    exit 1
fi

if [[ "$CONDA_DEFAULT_ENV" != "base" ]]; then
    echo "The 'conda' environment is not active. Please activate it before continuing."
    echo "To activate the 'conda' environment, run: conda activate"
    exit 1
fi

echo "Installing conda-forge packages..."
conda install -c conda-forge jq yq -y

echo "Cloning the MAP repository..."
cd $TOP
git clone https://github.com/sparcians/map.git

echo "Checking out the map_v2 branch..."
cd $MAP
git checkout map_v2

echo "Creating the Sparta Conda environment..."
./scripts/create_conda_env.sh sparta dev

echo "Setup process completed."
echo "Please activate the 'sparta' environment by running: conda activate sparta"
