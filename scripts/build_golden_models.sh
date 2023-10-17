#! /bin/bash
if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

mkdir -p $TOOLS/bin

# Spike
cd $CONDOR_TOP
git clone git@github.com:riscv/riscv-isa-sim.git
cd $SPIKE
mkdir -p build; cd build
../configure --prefix=$TOP/tools
make -j8 
make install

# Whisper
cd $CONDOR_TOP
git clone https://github.com/chipsalliance/VeeR-ISS.git whisper
cd $WHISPER
make -j8 
cp build-Linux/whisper $TOOLS/bin

