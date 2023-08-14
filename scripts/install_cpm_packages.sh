#! /bin/bash

if [ -v CONDOR_TOP ]; then 
   echo "Variable is set: $HOME"
else
   echo ""
   echo "*** ERROR ***"
   echo "*   Please set $CONDOR_TOP or $TOP and rerun this script"
   echo "*   <cd to work area>"
   echo "*   export CONDOR_TOP=`pwd` or source how-to/env/setuprc.sh"
   echo "*   <rerun this script>"
   echo "*** ERROR ***"
   echo ""
   return 1
fi

eval `ssh-agent`

git clone --recurse-submodules \
    git@github.com:Condor-Performance-Modeling/benchmarks.git
git clone git@github.com:Condor-Performance-Modeling/cam.git
git clone git@github.com:Condor-Performance-Modeling/tools.git
git clone git@github.com:Condor-Performance-Modeling/utils.git

