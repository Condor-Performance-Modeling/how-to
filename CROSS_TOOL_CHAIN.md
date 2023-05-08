# CROSS-TOOL-CHAIN
Documentation and tips for building the risc-v cross compiler toolchain
There are pre-built packages for these tools. The preferred method is to
use the pre-built tools.

# Pre-built tool chain available
I maintain a set for Ubuntu 22.04. Send me a slack for the link. Otherwise
instructions for building GNU tools is below.

--------------------------------------
# ToC

1. [Boot strapping the environment](#boot-strapping-the-environment)

1. [Set local environment variables](#set-local-environment-variables)

1. [Install the Ubuntu collateral](#install-the-ubuntu-collateral)

1. [Build the riscv gnu tool chain](#build-riscv-gnu-tool-chain)
    
--------------------------------------
# Boot strapping the environment

If you have not previously cloned the how-to repo follow these steps,
otherwise skip this section.

Presumably you are reading this how-to from the web or a local copy. This
section boot straps the how-to environment.

- Change directory to the place you want to install condor tools 
  and environment.
- Make a directory called condor
- cd to condor
- clone this condor performance modeling how-to repo


```
[cd workspace]
mkdir -p condor
cd condor
git clone git@github.com:Condor-Performance-Modeling/how-to.git
```
--------------------------------------
# Set local environment variables

Bash environment variables are presumed in the instructions that follow. 
These are exported to your shell. A script is available to automate setting 
these variables. You only need a subset of these variables for building the
tool chains.

```
cd condor
mkdir Downloads
source how-to/env/setupenv.sh
```

Once the script is sourced these variables will exist in your current shell. 
This is 

- TOP
    - This var points to where all CPM repo's will live. This is essentially /path/to/condor.
    - <b>export TOP=\`pwd\`</b>

- WGETTMP
    - Some packages require manual download using wget.
    - This a temporary directory for that purpose.
    - <b>export WGETTMP=$TOP/Downloads</b>

- PATCHES
    - A directory with pre-modified source files and patch files
    - <b>export PATCHES=$TOP/how-to/patches</b>

- KERNEL_5_8
    - A directory with environment scripts and resource files
    - <b>export KERNEL=$TOP/linux-5.8-rc4</b>

- CPM_ENV
    - A directory with environment scripts and resource files
    - <b>export CPM_ENV=$TOP/how-to/env</b>

- MAP
    - This var points to the Sparcians/Map repo copy
    - <b>export MAP=$TOP/map</b>

- OLYMPIA
    - This var points to the riscv-perf-model (aka Olympia) repo copy
    - <b>export OLYMPIA=$TOP/riscv-perf-model</b>

- RV_TOOLS_SRC
    - This var points to the tool chain source directory
    - <b>export RV_TOOLS_SRC=$TOP/riscv-gnu-toolchain</b>

- RV_BAREMETAL_TOOLS
    - This var points to the gnu bare metal tool chain install directory.
    - <b>export RV_BAREMETAL_TOOLS=$TOP/riscv64-unknown-elf</b>

- RV_LINUX_TOOLS
    - This var points to the gnu linux tool chain install directory.
    - <b>export RV_LINUX_TOOLS=$TOP/riscv64-unknown-linux-gnu</b>

- DROMAJO
    - This var points to the dromajo under riscv-perf-model
    - <b>export DROMAJO=$TOP/riscv-perf-model/traces/stf_trace_gen/dromajo</b>

--------------------------------------
# Install the Ubuntu collateral

Install the Ubuntu support packages

```
  sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev
  sudo apt install rapidjson-dev xz-utils autoconf automake autotools-dev 
  sudo apt install curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk 
  sudo apt install build-essential bison flex texinfo gperf libtool patchutils 
  sudo apt install bc zlib1g-dev libexpat-dev ninja-build
```

All in one line for easy cut/paste

```
sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev rapidjson-dev xz-utils autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build
```

--------------------------------------
# Install riscv gnu tool chain

Some estimates say ~7GB of space is needed.

There are pre-built versions of the bare metal and linux tools. See
Jeff to get the link. These versions can save hours of compile time.

## Pre-req and clone

There are two versions of the tool chain, linux and bare metal, these are
built from the same source, with different install prefixes. Be aware of the
PATH settings in the instructions, if you are building both.

```
  mkdir -p $RV_LINUX_TOOLS       (the linux tool chain install path)
  mkdir -p $RV_BAREMETAL_TOOLS   (the bare metal tool chain install path)
  git clone https://github.com/riscv-collab/riscv-gnu-toolchain
  cd riscv-gnu-toolchain
  git config http.sslVerify false
```

## Configure, make and install

### Linux tool version
Install path will be $RV_LINUX_TOOLS.

```
  export PATH=$RV_LINUX_TOOLS/bin:$PATH
  cd $RV_TOOLS_SRC
  rm -rf build
  mkdir build;cd build
  ../configure --prefix=$RV_LINUX_TOOLS --enable-multilib
  make linux    # gnu linux tool chain
```

### Bare metal version
Install path will be $RV_BAREMETAL_TOOLS.
```
  export PATH=$RV_BAREMETAL_TOOLS/bin:$PATH
  cd $RV_TOOLS_SRC
  rm -rf build
  mkdir build;cd build
  ../configure --prefix=$RV_BAREMETAL_TOOLS --enable-multilib
  make          #bare metal tool chain
```

