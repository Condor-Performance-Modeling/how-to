#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

if [[ -z "${CPM_DROMAJO}" ]]; then
  { echo "CPM_DROMAJO is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

mkdir -p $TOOLS/bin

git clone git@github.com:Condor-Performance-Modeling/cpm.dromajo.git cpm.dromajo

cd $CPM_DROMAJO
ln -s ../stf_lib

mkdir -p release; cd release
cmake .. 
make -j8;

cp cpm_dromajo $TOOLS/bin

