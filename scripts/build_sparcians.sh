#! /bin/bash

set -e

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "-E: CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; 
exit 1; }
fi

if ! [ "$CONDA_DEFAULT_ENV" == "sparta" ]; then
{
  echo "-E: sparta environment is not enabled";
  echo "-E: issue 'conda active sparta' and retry.";
  exit 1;
}
else
{
  echo "-I: sparta environment detected, proceeding";
}
fi

source "$TOP/how-to/scripts/git_clone_retry.sh"
  
cd $TOP

# MAP/Sparta
cd $MAP/sparta; mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc);
cmake --install . --prefix $CONDA_PREFIX

# Adding regress step for sanity
make -j$(nproc) regress

# Helios
pip install Cython==0.29.23
cd $MAP/helios; mkdir -p release; cd release
rm -rf *
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
cmake --install . --prefix $CONDA_PREFIX

# STF_LIB
cd $TOP

if [ -d "stf_lib" ]; then
  echo "-I: stf_lib exists, pulling latest changes."
  cd stf_lib && git pull
  cd ..
else
  echo "-W: stf_lib does not exist, cloning repo."
  clone_repository_with_retries "https://github.com/sparcians/stf_lib.git"
fi

cd stf_lib; mkdir -p release; cd release
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$(nproc)

