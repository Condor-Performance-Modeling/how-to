# Readme

# Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is a github organization.

CPM contains a number of repo's used by Condor.
Condor-Performance-Modeling/how-to contains documentation, patches and
support scripts. The steps that follow document building the Condor
perf modeling environment and provide instructions on how to use it.

----------------------------------------------------------

# ToC

1. [Choosing a host](#choosing-a-host)

1. [Creating a workspace](#creating-a-workspace)

1. [Boot strapping the environment](#boot-strapping-the-environment)

1. [Install Miniconda](#install-miniconda)

1. [CPM Environment Setup](#cpm-environment-setup)

1. [Boot Linux on CPM Dromajo](#boot-linux-on-cpm-dromajo)

1. [Proceed to benchmarks](#proceed-to-benchmarks)

1. [Optional builds](#optional-builds)

    1. [Build and Install stf_tools](#build-and-install-stf_tools)

    1. [Patching SimPoint](#patching-simpoint)

<!--
1. [Build the analysis tool suite](#build-the-analysis-tool-suite)
1. [Build the benchmark suite](#build-the-benchmark-suite)
1. [Running programs on CPM Dromajo](#running-programs-on-cpm-dromajo)
1. [Perf flow to-do list](#perf-flow-to-do-list)
1. [Using pipeline data views](#using-pipeline-data-views)
-->

----------------------------------------------------------

# Choosing a host
You should do most of your work on interactiveN or computeN.  (where N=1 as of 2023.11.03)

When you first access C-AWS you will land you on guiN. Once on guiN you 
should switch to interactiveN or computeN.

```
ssh interactive1
OR
ssh compute1
```

Do not run intensive jobs on the GUI machines. They are intended
for serving desktops and limited browser use.

<i>If you exceed the GUI machine limits your job may be unexpectedly terminated without much explanation. </i>

# Creating a workspace

The convention is to use /data/users for workspaces. It is not a good
idea to use your home directory due to size limits.

```
cd /data/users/$USER              # or your preferred workspace
mkdir condor; cd condor
git clone git@github.com:Condor-Performance-Modeling/how-to.git
source how-to/env/setuprc.sh
echo $TOP                         # this should not be empty
```

# Boot strapping the environment

If this is your first time through the install expand the details below.

If you have already done this skip to 'Install Miniconda'

If you have already installed Miniconda skip to 'Clone the CPM Repos'

<details>
  <summary> <b>EXPAND THIS SECTION IF THIS IS THE FIRST TIME YOU ARE CREATING A C-AWS WORKSPACE</b> </summary>
<br>
You must have an account with C-AWS, you must be registered with CPM.

You will want to have your ssh keys installed and registered with GitHub 
and ssh-agent. 

There are two* Ubuntu environments at present, Condor AWS aka C-AWS, and 
VCAD. C-AWS is Condor managed, with assistance from IT contractors. 

These instructions are not for the VCAD environment. See Jeff if 
you are creating a CPM environment in VCAD.

*Caveat: You can also use these instructions on a local machine not under 
C-AWS. The long term solution is to use your C-AWS account and resources. 

### Become member of Github CPM organization
You must be a member of Condor Performance Modeling (CPM) GitHub 
organization before you can access the private repos in this list.

Send me your account name via slack or email. I will send you back a
note when I have added your account to CPM.

### Request an account on C-AWS
You can skip this step short term, if you are running on a local linux machine.

Send me a slack or email telling me you need a C-AWS account. I will send
you back the instructions on how to get an account and then how to access
it.  I'm doing it this way to avoid exposing the process, sorry.

## Create and register your ssh keys

Once you have access to a linux machine generate your public SSH keys. You will
add this key to your github account.

### Create your keys
Your home directory is /nfshome/\<login id\>

CD to your home and create your ssh keys. Use the default file name and path.

```
  aw01ut01: cd $HOME
  aw01ut01: ssh-keygen

  Enter file in which to save the key (/nfshome/yourlogin/.ssh/id_rsa): 
  Enter passphrase (empty for no passphrase): <your passphrase>
```

<b>Do not use an empty passphrase. </b>

```
  Enter same passphrase again: <your passphrase>

  aw01ut01> chmod 700 ~/.ssh
  aw01ut01> chmod 600 ~/.ssh/*
```

<b>You will use your passphrase in place of a password when cloning and pushing.</b>

### Add your keys to ssh-agent
If you do this in a terminal you will no longer have to supply your phrase for GitHub transactions.

```
  eval `ssh-agent`
  ssh-add $HOME/.ssh/id_rsa
```

More details can be found [GITHUB](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [ATLASSIAN](https://www.atlassian.com/git/tutorials/git-ssh)

### Register your keys with github

Follow the instructions [GITHUB-2](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

Note your ssh public key is in this file $HOME/.ssh/id_rsa.pub. The contents
of this file are pasted at step 7.

## Choose a host
There are two types of machines, interactiveN and computeN.
(As of 2024 N=1, this will change)

The instructions for NoMachine will land you on gui1. Your desktop is served by gui1.

It is intended only for serving desktops. If you run anything substantial you
risk cratering the whole system for everyone. There are load monitors that will
kill your job if you make a mistake. If you manage to crater the system please
let me know so we can adjust the monitors.

From gui1 you should ssh to interactiveN or computeN.

gui1> ssh interactive1

At present the distinction, interactive/compute, is small. In the future logging in to computeN 
will only be possible through LSF but this is months away.

Note interactive1 has better disk performance than compute1. 

## Create a work area
Create a work area in C-AWS at /data/users/<login id>

interactive1> cd /data/users
interactive1> mkdir your_login_id
interactive1> cd your_login_id, etc etc.

/data is NFS mounted across all interactive and compute machines.

## Install the Ubuntu collateral

You normally do not need to do this. It has been done for you.

<details>
  <summary>Details: Install the Ubuntu collateral</summary>

Install the Ubuntu support packages:
```
  sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev
  sudo apt install rapidjson-dev xz-utils autoconf automake autotools-dev
  sudo apt install curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk
  sudo apt install build-essential bison flex texinfo gperf libtool patchutils
  sudo apt install bc zlib1g-dev libexpat-dev ninja-build device-tree-compiler
  sudo apt install libboost-all-dev  libsqlite3-dev libhdf5-serial-dev
  sudo apt install libzstd-dev gcc-multilib clang-tidy pkg-config
  sudo apt install tkdiff traceroute mtr scons okular clang-format pylint
  sudo apt install liblzma-dev libbz2-dev texlive-full xpdf

NOTE: im working through the qt requirements - this will change
  sudo add-apt-repository universe
  sudo apt install qt-base6-dev qt6-qmake

NOTE: im working through the Node.js requirements - this will change
  sudo apt install npm nodejs pip
  sudo pip install flask docopt path_and_address grip numpy seaborn
```

All in one line for easy cut/paste:
```
sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev rapidjson-dev xz-utils autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build device-tree-compiler libboost-all-dev  libsqlite3-dev libhdf5-serial-dev libzstd-dev gcc-multilib clang-tidy pkg-config tkdiff traceroute mtr scons okular clang-format pylint liblzma-dev libbz2-dev texlive-full xpdf
```

</details>

</details> <!-- end of Linux, C-AWS and VCAD environments -->

----------------------------------------------------------

# Install Miniconda

Miniconda package manager is used by Sparcians. 

<b>NOTE: if you have an existing miniconda install you just need 
to activate your conda environment:</b>

```
conda activate
```

<b>With correct activation your prompt will start with (base).</b>

If you need to install or re-install Miniconda expand the section
'Details: How to install miniconda'

<details>
If you have a Miniconda environment already installed you

If you have done this once
you can skip this step. The base conda packages are stored in your home
directory. 

That means if you are installing multiple $TOP environments you
only need to install miniconda once.

  <summary>Details: How to install miniconda</summary>

<br>

```
cd <your work area>  # typically /data/users/<username>/condor
bash /data/tools/env/Miniconda3-py311_23.9.0-0-Linux-x86_64.sh

..please review the license agreement....
Do you accept the license terms? [yes|no]
[no] >>> yes

Do you wish the installer to initialize Miniconda3
by running conda init? [yes|no]
[no] >>> yes

```
<br>

In accepting the license:

- I am using the default install location
- I am allowing the installer to run conda init
- I am allowing the installer to modify my .bashrc
- I manually move the conda init lines from .bashrc to my .bashrc.private

The instructions tell you how to disable miniconda activation at 
startup

- conda config --set auto_activate_base false

- I am not executing this command

- Installing miniconda creates a .condarc  file in your home. 
  - To fully uninstall conda this file should also be deleted.
  - For information only, the auto_activate_base setting is stored in this
    file


<i> if you are in a managed environment, like VCAD, make sure you move the 
added .bashrc lines to a private rc file.</i>

<H2>Close this terminal and open a new terminal</H2>

Your prompt should start with <b>(base)</b>
</details>

</details> <!-- end of Linux, C-AWS and VCAD environments -->

----------------------------------------------------------

# CPM Environment Setup

## Prequisites

Verify your conda environment is active. (base) should be in your prompt.

```bash
conda activate
cd /data/users/$USER/condor   # or your work area
source how-to/env/setuprc.sh
```

Make sure that your SSH key was added to the ssh-agent to clone repositories without interruptions. 

```bash
  eval `ssh-agent`
  ssh-add $HOME/.ssh/id_rsa
```

## Setup Instructions

Run script to set up Conda environment:

```bash
bash how-to/scripts/conda_env_setup.sh
conda activate sparta
```

Your prompt should start with (sparta) after activation. Then run:

```bash
bash how-to/scripts/cpm_env_setup.sh
```

This script completes the following stages:

1. Building Sparcians components
1. Building the Linux collateral
1. Building and Installing the CPM Repos
1. Building and Installing Olympia

## Troubleshooting

If the `cpm_env_setup.sh` setup script fails, it's designed to be re-run. It will pick up the process from the last completed stage. Alternatively, steps can be completed manually if needed (see the details section below).

<details>
  <summary>Details: Install the Sparcians repos</summary>

# Install the Sparcians repos

## Install the MAP Miniconda components

Verify your conda environment is active. '(base)' should be in your prompt.

```
conda activate
cd /data/users/$USER/condor   # or your work area
source how-to/env/setuprc.sh

conda install -c conda-forge jq yq 
Proceed ([y]/n)? y
```

## Create the Sparta Conda environment

This section builds and installs the conda environment used by Map.

If you have previously installed MAP you will have a MAP Conda
environment available and you may receive the "prefix already exists"
message when creating the conda environment. This is benign.

```
cd $TOP
git clone https://github.com/sparcians/map.git
cd $MAP
git checkout map_v2
./scripts/create_conda_env.sh sparta dev
conda activate sparta
conda install yaml-cpp
```

Your prompt should start with (sparta) after activation.

## Building Sparcians components

This builds MAP/Sparta, helios and STF_LIB.

```
conda activate sparta
cd $TOP
bash how-to/scripts/build_sparcians.sh
```

<details> 
  <summary>Details: Building Map components step by step</summary>

```
cd $TOP

# MAP/Sparta
cd $MAP/sparta; mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j32;
cmake --install . --prefix $CONDA_PREFIX

# Adding regress step for sanity
make -j32 regress

# Helios
pip install Cython==0.29.23
cd $MAP/helios; mkdir -p release; cd release
rm -rf *
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j32
cmake --install . --prefix $CONDA_PREFIX

# STF_LIB
cd $TOP

if ! [ -d "stf_lib" ]; then
{
  echo "-W: stf_lib does not exist, cloning repo."
  git clone https://github.com/sparcians/stf_lib.git
}
fi

cd stf_lib; mkdir -p release; cd release
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j32
```
</details>

<!--
  829  git switch map_v2
  830  git log
  831  git checkout 4bb21e8a20bfb83354bb3d54fb067100d4f01a47
-->
</details>

----------------------------------------------------------

<details>
  <summary>Details: Install the Linux collateral</summary>

# Install the Linux collateral

## Link the cross compilers

If necessary create links to the cross compilers

```
  cd $TOP
  ln -sfv /data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1 riscv64-unknown-elf
  ln -sfv /data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1 riscv64-unknown-linux-gnu
```

## PATH check
Check that riscv64-unknown-linux-gnu-gcc is in your path.
```
which riscv64-unknown-linux-gnu-gcc
```
If not, add it to your PATH variable as shown.
```
export PATH=$RV_LINUX_TOOLS/bin:$PATH
```
CROSS_COMPILE is now set in the CPM environment RC file.  To set it manually:
```
export CROSS_COMPILE=riscv64-unknown-linux-gnu-
```

## Build the Linux collateral

This step downloads and builds the kernel, file system and OpenSBI.


```
cd $TOP
bash how-to/scripts/build_linux_collateral.sh
```

<details>
  <summary>Details: Building the linux collateral step by step</summary>

```
cd $CONDOR_TOP
mkdir -p $TOOLS/riscv-linux

# Double check the links to the cross compilers

if [ ! -L riscv64-unknown-elf ]; then
  ln -sfv /data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1 riscv64-unknown-elf
fi

if [ ! -L riscv64-unknown-linux-gnu ]; then
  ln -sfv /data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1 riscv64-unknown-linux-gnu
fi

wget --no-check-certificate -nc \
        https://git.kernel.org/torvalds/t/linux-5.8-rc4.tar.gz
tar -xf linux-5.8-rc4.tar.gz
make -C linux-5.8-rc4 ARCH=riscv defconfig
make -C linux-5.8-rc4 ARCH=riscv -j32
mkdir -p $TOOLS/riscv-linux
cp linux-5.8-rc4/arch/riscv/boot/Image $TOOLS/riscv-linux/Image

# Build the file system

wget --no-check-certificate \
         https://github.com/buildroot/buildroot/archive/2020.05.1.tar.gz
tar xf 2020.05.1.tar.gz
cp $CONDOR_TOP/how-to/patches/config-buildroot-2020.05.1 buildroot-2020.05.1/.config

# This make will fail, followed by a patch
make -C buildroot-2020.05.1 -j32
cp $PATCHES/c-stack.c \
          ./buildroot-2020.05.1/output/build/host-m4-1.4.18/lib/c-stack.c

# This make will also fail, followed by another patch
make -C buildroot-2020.05.1 -j32
cp $PATCHES/libfakeroot.c \
          ./buildroot-2020.05.1/output/build/host-fakeroot-1.20.2/libfakeroot.c

# This make should not fail
sudo make -C buildroot-2020.05.1 -j32

if ! [ -f $BUILDROOT/output/images/rootfs.cpio ]; then
  echo "-E: rootfs.cpio build failure"; exit 1;
fi

cp $BUILDROOT/output/images/rootfs.cpio $CONDOR_TOP/tools/riscv-linux

# Build OpenSBI

cd $CONDOR_TOP
git clone https://github.com/riscv/opensbi.git
cd $OPENSBI
make PLATFORM=generic -j32
cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin $TOOLS/riscv-linux

```

</details>
</details>

----------------------------------------------------------

<details>
  <summary>Details: Install the CPM Repos</summary>

# Install the CPM Repos

CPM -> Condor Performance Modeling

This install the CPM repos: benchmarks, CAM, tools, utils, cpm.riscv-perf-model, cpm.dromajo

```
cd $TOP
bash how-to/scripts/build_cpm_repos.sh

```

<details>
  <summary>Details: Installing the CPM repo's step by step</summary>

<br>

```
#! /bin/bash

set -e

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

cd $TOP
# create the tools directories explicitly here, to avoid creating
# files w/ the directory names
mkdir -p $TOOLS/bin
mkdir -p $TOOLS/lib
mkdir -p $TOOLS/include
mkdir -p $TOOLS/riscv-linux

# CAM
if ! [ -d "$CAM" ]; then
{
  echo "-W: cam does not exist, cloning repo."
  git clone git@github.com:Condor-Performance-Modeling/cam.git
}
fi

cd $CAM;

mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j32;
cmake --install . --prefix $CONDA_PREFIX

# Adding regress step for sanity
make -j32 regress

# Dromajo fork
cd $TOP

if ! [ -d "cpm.dromajo" ]; then
{
  echo "-W: cpm.dromajo does not exist, cloning repo."
  git clone git@github.com:Condor-Performance-Modeling/dromajo.git cpm.dromajo
}
fi

cd $CPM_DROMAJO
git submodule update --init --recursive

# The stf version
mkdir -p build; cd build
cmake ..
make -j32
cp dromajo $TOOLS/bin/cpm_dromajo

# The stf + simpoint version
cd ..
mkdir -p build-simpoint; cd build-simpoint
cmake .. -DSIMPOINT=On
make -j32
cp dromajo $TOOLS/bin/cpm_simpoint_dromajo

# -------------------------------------------------------
# Sym link the cross compilers
# -------------------------------------------------------
if [ ! -L riscv64-unknown-elf ]; then
  ln -sfv /data/tools/riscv-embecosm-embedded-ubuntu2204-20240407-14.0.1 riscv64-unknown-elf
fi

if [ ! -L riscv64-unknown-linux-gnu ]; then
  ln -sfv /data/tools/riscv64-embecosm-linux-gcc-ubuntu2204-20240407-14.0.1 riscv64-unknown-linux-gnu
fi

# -------------------------------------------------------
# Repos
# -------------------------------------------------------

cd $TOP

# benchmarks
if [ ! -d benchmarks ]; then
  git clone --recurse-submodules \
            git@github.com:Condor-Performance-Modeling/benchmarks.git
fi

# Tools
if [ ! -d tools ]; then
  git clone git@github.com:Condor-Performance-Modeling/tools.git
fi

# Utils
if [ ! -d utils ]; then
  git clone git@github.com:Condor-Performance-Modeling/utils.git
fi


```

</details>
</details>

----------------------------------------------------------

<details>
  <summary>Details: Build and Install Olympia</summary>

# Build and Install Olympia

This step is optional. Olympia is the reference model. CAM is a fork of the
reference model. Changes to Olympia are selectively added to CAM. The
Olympia install directory is riscv-perf-sim.

You must have the sparta conda environment activated.

```
cd $TOP
bash how-to/scripts/build_olympia.sh
```

<details>
  <summary>Details: Building Olympia step by step</summary>

```
cd $TOP
mkdir -p tools/bin
git clone --recursive https://@github.com/riscv-software-src/riscv-perf-model.git

cd $OLYMPIA; mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
make -j8; cmake --install . --prefix $CONDA_PREFIX
cp olympia $TOOLS/bin/olympia
```

</details>
</details>

----------------------------------------------------------

# Boot Linux on CPM Dromajo

The above steps create the necessary collateral to boot linux on CPM 
Dromajo.

The steps above create collateral files in $TOOLS/riscv-linux

<b>login is root, password is root</b> for both versions.

## Boot linux - CPM DROMAJO 
Copy the images/etc from previous steps to the CPM Dromajo run directory.
```
cd $TOP
mkdir -p $CPM_DROMAJO/run
cp $TOOLS/riscv-linux/* $CPM_DROMAJO/run
cp $PATCHES/cpm.boot.cfg  $CPM_DROMAJO/run

cd $CPM_DROMAJO/run
$TOOLS/bin/cpm_dromajo --ctrlc --stf_essential_mode --stf_priv_modes USHM --stf_trace example.stf boot.cfg
```

<!--
TMI

If you do not need STF trace generation the command line can be simplified
```
$TOOLS/bin/cpm_dromajo --ctrlc cpm.boot.cfg   # enable ctrl-c exit
$TOOLS/bin/cpm_dromajo --trace 0 cpm.boot.cfg # enable console tracing
```
-->

----------------------------------------------------------
# Build and Install the Golden Models

## Exit Conda

<b>You must deactivate the conda environment before compiling the golden models.</b>

Deactivate once to exit the sparta environment, once again to exit the base conda
environment.

Your prompt should not show (base) or (sparta) when you have
successfully deactivated the environments.

```
  conda deactivate     # leave sparta
  conda deactivate     # leave base
```

## Build the Golden Models

```
cd $TOP
bash how-to/scripts/build_golden_models.sh
```

<details>
  <summary>Build the golden models step by step</summary>

```
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

```

</details>

----------------------------------------------------------
# Proceed to benchmarks

The remaining instructions are in $BENCHMARKS/README.md.

----------------------------------------------------------
# Optional builds

<b> The following steps are for information only.  </b>

<b> You do not normally need to proceed beyond this point. </b>

## Build and Install stf_tools

This step is optional but the tools created are very helpful in working with the STF traces.

The `github` repo is here:  https://github.com/sparcians/stf_tools

Log into `interactive1`.  On this machine, the following libraries have already been installed:
```
sudo apt-get install libmpc-dev liblzma-dev libbz2-dev
```

If you are on a different machine, you may need to install these libraries yourself.

```
cd $TOP
conda activate sparta
git clone git@github.com:sparcians/stf_tools
cd stf_tools

git checkout 161b983    # This SHA works; this flow has not been tested with later SHAs
git submodule update --init --recursive

# Here we hack the cmake file to disable some warnings.  This should be root-caused and fixed at some point
sed -i 's/-Wextra -pedantic -Wconversion/-pedantic/' CMakeLists.txt

mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j8
```

If a higher version of CMake is required than what was found, upgrade the version. With the sparta environment enabled try:

```
conda install cmake
```

The tools can be found in `stf_tools/release/tools`.  Each tool is in its own subdirectory.
Here are some tools you may want to play with to begin:
```
cd $TOP/stf_tools/release/tools
stf_count/stf_count $CAM/traces/dhry_riscv.zstf
stf_dump/stf_dump $CAM/traces/dhry_riscv.zstf |head -40
stf_imem/stf_imem $CAM/traces/dhry_riscv.zstf |head -40
```
----------------------------------------------------------
## Patching SimPoint

SimPoint is installed in C-AWS at /data/tools/SimPoint.3.2.

You do not need to install another copy for the standard flow.


## About Simpoint

For the description of Simpoint see this url
```
https://cseweb.ucsd.edu/~calder/simpoint/
```
The releases are available through this url:
```
https://cseweb.ucsd.edu/~calder/simpoint/software-release.htm
```

## Building Simpoint from source

For modern compilers v3.2 needs to be patched. I use this script to 
patch new builds of 3.2

```
$TOP/how-to/patches/patch_simpoint.3.2.sh
```

The process is typically:

```
tar xf SimPoint.3.2.tar.gz
cd SimPoint.3.2/analysiscode
bash $TOP/how-to/patches/patch_simpoint.3.2.sh
cd ..
make -j8
```

