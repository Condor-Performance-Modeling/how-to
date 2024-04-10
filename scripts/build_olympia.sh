#! /bin/bash

set -e

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

source "$TOP/how-to/scripts/git_clone_retry.sh"

if ! [ -d "$OLYMPIA" ]; then
{
  echo "-W: riscv-perf-model does not exist, cloning repo."
  clone_repository_with_retries "https://github.com/riscv-software-src/riscv-perf-model.git" "riscv-perf-model" "--recursive"
}
fi

mkdir -p $TOOLS/bin
cd $OLYMPIA;

git apply $TOP/how-to/patches/scoreboard_patch_map_v2.patch || true

mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release 
make -j$(nproc);
cmake --install . --prefix $CONDA_PREFIX

make -j$(nproc) regress

cp olympia $TOOLS/bin/olympia

