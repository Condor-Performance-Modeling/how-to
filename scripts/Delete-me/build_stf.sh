#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

mkdir -p $TOOLS/bin
git clone https://github.com/sparcians/stf_lib.git

cd stf_lib; mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8; 

