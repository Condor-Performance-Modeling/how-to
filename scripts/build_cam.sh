#! /bin/bash

if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "-E: CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; 
exit 1; }
fi

if [[ -z "${CAM}" ]]; then
{
  echo "-E: CAM is undefined, execute 'source how-to/env/setuprc.sh'"; 
  exit 1;
}
fi

if ! [ -d "$CAM" ]; then
{
  echo "-W: cam does not exist, cloning repo."
  git clone git@github.com:Condor-Performance-Modeling/cam.git
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
cd $CAM;

mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
make -j8; cmake --install . --prefix $CONDA_PREFIX

cp cam $TOOLS/bin/cam
