#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

if [[ -z "${CPM_DROMAJO}" ]]; then
  { echo "CPM_DROMAJO is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

mkdir -p $TOOLS/bin

if ! [ -d "$CPM_DROMAJO" ]; then
{
  echo "-W: cpm.dromajo does not exist, cloning repo."
  git clone git@github.com:Condor-Performance-Modeling/dromajo.git cpm.dromajo
}
fi

cd $CPM_DROMAJO
# Based on main dromajo SHA:f3c3112
git checkout jeffnye-gh/dromajo_stf_update

ln -s ../stf_lib

# The stf version
mkdir -p build; cd build
cmake .. 
make -j8
cp dromajo $TOOLS/bin/cpm_dromajo

# The stf + simpoint version
cd ../run
git clone https://github.com/southerngs/simpoint.git
make -C simpoint

cd ..
mkdir -p build-simpoint; cd build-simpoint
cmake .. -DSIMPOINT=On
make -j8
cp dromajo $TOOLS/bin/cpm_simpoint_dromajo
