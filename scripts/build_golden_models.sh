#! /bin/bash
if [[ -z "${CONDOR_TOP}" ]]; then
  { echo "CONDOR_TOP is undefined, execute 'source how-to/env/setuprc.sh'"; exit 1; }
fi

if [[ -z "${SPIKE}" ]]; then
{
  echo "-E: SPIKE is undefined, execute 'source how-to/env/setuprc.sh'";
  exit 1;
}
fi

if [[ -z "${WHISPER}" ]]; then
{
  echo "-E: WHISPER is undefined, execute 'source how-to/env/setuprc.sh'";
  exit 1;
}
fi

if ! [ -d "$SPIKE" ]; then
{
  echo "-W: riscv-isa-sim does not exist, cloning repo."
  git clone git@github.com:riscv/riscv-isa-sim.git
}
fi

if ! [ -d "$WHISPER" ]; then
{
  echo "-W: whisper does not exist, cloning repo."
  git clone https://github.com/chipsalliance/VeeR-ISS.git whisper
}
fi

mkdir -p $TOOLS/bin

# once for sparta, once for base
conda deactivate
conda deactivate

# Spike
cd $SPIKE
mkdir -p build; cd build
../configure --prefix=$TOP/tools
make -j8 
make install

# Whisper
cd $WHISPER
make -j8 
cp build-Linux/whisper $TOOLS/bin

