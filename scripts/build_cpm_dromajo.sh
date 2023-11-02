#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

if [[ -z "${CPM_DROMAJO}" ]]; then
  { echo "CPM_DROMAJO is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

mkdir -p $TOOLS/bin

git clone git@github.com:Condor-Performance-Modeling/dromajo.git cpm.dromajo

cd $CPM_DROMAJO
# Based on main dromajo SHA:f3c3112
git checkout jeffnye-gh/dromajo_stf_update

ln -s ../stf_lib

mkdir -p build; cd build
cmake .. 
make -j8;

cp dromajo $TOOLS/bin/cpm_dromajo

