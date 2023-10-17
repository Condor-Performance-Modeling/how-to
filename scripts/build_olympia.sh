#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

if [[ -z "${OLYMPIA}" ]]; then
  { echo "OLYMPIA is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

mkdir -p $TOOLS/bin
git clone --recursive https://@github.com/riscv-software-src/riscv-perf-model.git

cd $OLYMPIA; mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
make -j8; cmake --install . --prefix $CONDA_PREFIX
cp olympia $TOOLS/bin/olympia

