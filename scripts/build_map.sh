#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

if [[ -z "${MAP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

cd $MAP/sparta; mkdir release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8
cmake --install . --prefix $CONDA_PREFIX

cd $MAP/helios; mkdir release; cd release
cmake -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta ..
make -j8
cmake --install . --prefix $CONDA_PREFIX

