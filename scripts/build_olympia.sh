#! /bin/bash
if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "-E: CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; 
exit 1; }
fi

if [[ -z "${OLYMPIA}" ]]; then
{
  echo "-E: OLYMPIA is undefined, execute 'source how-to/env/setuprc.sh'"; 
  exit 1;
}
fi

if ! [ -d "$OLYMPIA" ]; then
{
  echo "-W: riscv-perf-model does exist cloning repo."
  git clone --recursive https://@github.com/riscv-software-src/riscv-perf-model.git
}
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
  
mkdir -p $TOOLS/bin
cd $OLYMPIA;

mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
make -j8; cmake --install . --prefix $CONDA_PREFIX

cp olympia $TOOLS/bin/olympia
