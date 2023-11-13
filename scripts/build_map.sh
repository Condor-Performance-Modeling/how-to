#! /bin/bash
# FIXME: this does not work due to problem integrating conda
# shell, script does not detect conda properly
if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

if [[ -z "${MAP}" ]]; then
  { echo "MAP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

cd $TOP

if ! [ -d "$MAP" ]; then
  echo "-W: $MAP does not exist, cloning map/sparta repo."
  git clone https://github.com/sparcians/map.git
  cd $MAP
#  echo "-W: git check out of SHA 2adb710"
  git checkout map_v2
  ./scripts/create_conda_env.sh sparta dev
else
  echo "-I: found existing $MAP proceeding with build."
fi

conda activate sparta
conda install yaml-cpp

cd $MAP/sparta; mkdir release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j16
cmake --install . --prefix $CONDA_PREFIX

cd $MAP/helios; mkdir release; cd release
cmake -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta ..
make -j16
cmake --install . --prefix $CONDA_PREFIX
