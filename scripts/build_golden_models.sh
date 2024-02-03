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

mkdir -p $TOOLS/bin

# Spike
cd $TOP

if ! [ -d "$SPIKE" ]; then
{
  echo "-W: riscv-isa-sim does not exist, cloning repo."
  git clone git@github.com:riscv/riscv-isa-sim.git
}
fi

cd $SPIKE
mkdir -p build; cd build
../configure --prefix=$TOP/tools
make -j32 
make install

# Whisper
cd $TOP

if ! [ -d "$WHISPER" ]; then
{
  echo "-W: whisper does not exist, cloning repo."
  git clone https://github.com/chipsalliance/VeeR-ISS.git whisper
}
fi

cd $WHISPER
make -j32
cp build-Linux/whisper $TOOLS/bin

