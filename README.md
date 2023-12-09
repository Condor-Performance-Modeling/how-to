# Readme 

# Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is a github organization. 

CPM contains a number of repo's used by Condor. 
Condor-Performance-Modeling/how-to contains documentation, patches and 
support scripts. The steps that follow document building the Condor 
perf modeling environment and provide instructions on how to use it.

--------------------------------------
# ToC

1. [Choosing a host](#choosing-a-host)
   
1. [Boot strapping the environment](#boot-strapping-the-environment)

1. [Clone the CPM Repos](#clone-the-cpm-repos)

1. [Install the RISCV GNU Tool Chain](#install-the-riscv-gnu-tool-chain)

1. [Build and Install MAP](#build-and-install-map)

1. [Build and Install CAM](#build-and-install-cam)

1. [Build and Install Olympia](#build-and-install-olympia)

1. [Build STF Lib](#build-stf-lib)

1. [Build CPM Dromajo](#build-cpm-dromajo)

1. [Build the Linux Kernel and File System](#build-the-linux-kernel-and-file-system)

1. [Build OpenSBI](#build-opensbi)

1. [Build and Install the Golden Models](#build-and-install-the-golden-models)

1. [Boot Linux on CPM Dromajo](#boot-linux-on-cpm-dromajo)

1. [Cloning the Benchmark Repo](#cloning-the-benchmark-repo)

1. [Patching SimPoint](#patching-simpoint)

<!--
1. [Build the analysis tool suite](#build-the-analysis-tool-suite)
1. [Build the benchmark suite](#build-the-benchmark-suite)
1. [Running programs on CPM Dromajo](#running-programs-on-cpm-dromajo)
1. [Perf flow to-do list](#perf-flow-to-do-list)
1. [Using pipeline data views](#using-pipeline-data-views)
-->

--------------------------------------
# Choosing a host
You should do most of your work on interactiveN or computeN.  (where N=1 as of 2023.11.03)

When you first access C-AWS you will land you on guiN. Once on guiN you 
should switch to interactiveN or computeN.

```
ssh interactive1
OR
ssh compute1
```

## Details
There are three types of machines: gui, interactive and compute.

GUI machines are sized only big enough to serve your desktop. Interactive machines are intended for development work. Compute machines are intended as sim-farm machines. As of 2023.11 the distinction between interactive and compute machines is only conventional. You can safely do this if the interactive machines are not performing well.

```
ssh compute1
```

Running compute or memory intensive jobs on GUI machines will result in some undesirable behavior.
Your job may run slowly. Your job may be unexpectedly terminated without much explanation.

# Boot strapping the environment

Presumably you are reading this how-to from the web or a local copy.  This
section contains instructions to boot strap the Condor Performance Modeling 
(CPM) environment.

## Linux, C-AWS and VCAD environments

In order to proceed you need a linux machine with git installed. In 
production this machine would be part of the C-AWS domain. In development
local linux machines are supported. 

### DETAILS ABOUT THE ENVIRONMENT SETUP

<b>EXPAND THE DETAILS AND FOLLOW THE STEPS IF THIS IS THE FIRST TIME
YOU ARE CREATING A C-AWS WORKSPACE</b>

<details>
  <summary> <b>Important details about C-AWS and your account</b> </summary>

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

## Create and register your ssh keys.

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

NOTE: im working through the qt requirements - this will change
  sudo add-apt-repository universe
  sudo apt install qt-base6-dev qt6-qmake

NOTE: im working through the Node.js requirements - this will change
  sudo apt install npm nodejs pip
  sudo pip install flask docopt path_and_address grip
```

All in one line for easy cut/paste:

```
sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev rapidjson-dev xz-utils autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build device-tree-compiler libboost-all-dev libsqlite3-dev libhdf5-serial-dev libzstd-dev gcc-multilib qt5-dev qt5-qmake pkg-config clang-tidy npm nodejs
```
</details>


## Install Miniconda

Miniconda package manager is used by Sparcians. If you have done this once
you can skip this step. The base conda packages are stored in your home
directory. 

That means if you are installing multiple $TOP environments you
only need to install miniconda once.

<b>NOTE: if you have an existing miniconda install you need to activate your conda environment:</b>

```
conda activate
```

With correct activation your prompt will start with (base).

<details>
  <summary>Details: How to install miniconda</summary>

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

```
cd <your work area>  # typically /data/users/<username>/condor
sh /data/tools/env/Miniconda3-py311_23.9.0-0-Linux-x86_64.sh

..please review the license agreement....
Do you accept the license terms? [yes|no]
[no] >>> yes

Do you wish the installer to initialize Miniconda3
by running conda init? [yes|no]
[no] >>> yes

```

<i> if you are in a managed environment, like VCAD, make sure you move the 
added .bashrc lines to a private rc file.</i>

<b>Close this terminal and open a new terminal</b>

Your prompt should start with <b>(base)</b>
</details>

</details> <!-- end of Linux, C-AWS and VCAD environments -->

<!--
Old miniconda path
wget --no-check-certificate https://repo.anaconda.com/miniconda/

Miniconda3-py311_23.9.0-0-Linux-x86_64.sh

or

Miniconda3-latest-Linux-x86_64.sh

another id test

-->
-----------------------------------------------------------
# Clone the CPM Repos

Clone the How-To repo locally, it contains settings which are assumed by
the remaining instructions, as well as patches for the tools.

The process is:

- Change directory to the place you want to install condor tools
  and environment.
- Make a directory called condor
- cd to condor
- clone the condor performance modeling how-to repo

```
[cd workspace]

mkdir condor; cd condor

eval `ssh-agent`
ssh-add $HOME/.ssh/id_rsa
<enter pass phrase>

git clone git@github.com:Condor-Performance-Modeling/how-to.git

source how-to/env/setuprc.sh  # useful env variables

bash how-to/scripts/base_repos.sh
```

<details> 
  <summary>Details: Installing the base repo's step by step</summary>

```
ln -s /tools/riscv64-unknown-elf
ln -s /tools/riscv64-unknown-linux-gnu
git clone --recurse-submodules git@github.com:Condor-Performance-Modeling/benchmarks.git
git clone git@github.com:Condor-Performance-Modeling/cam.git
git clone git@github.com:Condor-Performance-Modeling/tools.git
git clone git@github.com:Condor-Performance-Modeling/utils.git
git clone --recurse-submodules git@github.com:Condor-Performance-Modeling/riscv-perf-model.git cpm.riscv-perf-model
git clone git@github.com:Condor-Performance-Modeling/dromajo cpm.dromajo
```

</details>

Once the script completes:

    - The cross compilers will be linked.
    - The CPM repos benchmarks, cam, tools and utils will be cloned
    - The CPM forks of riscv-perf-model and dromajo will also be cloned.


The setuprc.sh script is documented here: [LINK](./SET_LOCAL_ENV.md)

----------------------------------------------------------
# Install RISCV GNU Tool Chain

Links to the pre-installed tools were created in the previous step.

<details> 
  <summary>Details: Cross compiler setup</summary>

You only need to create links to the pre-installed tools. These are C-AWS paths.

```
cd $TOP
ln -s /tools/riscv64-unknown-elf
ln -s /tools/riscv64-unknown-linux-gnu
```

</details>

----------------------------------------------------------

# Build and Install MAP

## Install the MAP Miniconda components

```
cd <workspace>/condor
source how-to/env/setuprc.sh

conda activate
conda install -c conda-forge jq yq 
Proceed ([y]/n)? y
```

## Install MAP

This section builds and installs Map and it's components: Sparta and Sparta's 
conda environment, and Helios/Argos

If you have previously installed MAP you will have a MAP Conda environment
available and you may receive the "prefix already exists"
message when creating the conda environment. This is benign.

```
cd $TOP
git clone https://github.com/sparcians/map.git
cd $MAP
git checkout map_v2
./scripts/create_conda_env.sh sparta dev
conda activate sparta
conda install yaml-cpp

cd $MAP/sparta; mkdir release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j16
cmake --install . --prefix $CONDA_PREFIX

cd $MAP/helios; mkdir release; cd release
cmake -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta ..
make -j16
cmake --install . --prefix $CONDA_PREFIX
```

<!--
<em> Script automation was backed out in this version due to issues with
conda detection.</em>

```
  cd $TOP
  bash how-to/scripts/build_map.sh
```

<details>
  <summary> Build and install map step by step </summary>

```
```

</details>
-->

Your prompt should now start with (sparta), then:



--------------------------------------------------------
# Build and Install CAM

## Clone CAM

This step was previously executed in "Clone the CPM Repos"

Skip this step if you have previously cloned CAM.
 
```
  cd $TOP
  git clone git@github.com:Condor-Performance-Modeling/cam.git
```

## Build CAM

This builds CAM, the Cuzco Architecture Model.

You must have the sparta conda environment activated.

```
  cd $TOP
  conda activate sparta
  bash how-to/scripts/build_cam.sh
```

<details>
  <summary>Details: Building CAM step by step</summary>

```
cd $TOP
conda activate sparta
mkdir -p tools/bin
git clone git@github.com:Condor-Performance-Modeling/cam.git
cd $CAM; mkdir -p release; cd release
cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
make -j8; cmake --install . --prefix $CONDA_PREFIX
cp cam $TOP/tools/bin/cam
```

</details>

--------------------------------------------------------
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

--------------------------------------------------------
# Build STF Lib

STF is a library supporting the Simulation Trace Format.

Notes: riscv-perf-model checks out these SHAs
```
'mavis': checked out 'ba3d7e4141cd1dbce03cf7eb5481179836f2ac0f'
'stf_lib': checked out '5a3841de3ea97941de481414c897b981c05efda3'
```


```
cd $TOP
bash how-to/scripts/build_stf.sh
```

<details>
  <summary>Details: Building the STF library step by step</summary>

```
cd $TOP
git clone https://github.com/sparcians/stf_lib.git
cd stf_lib; mkdir -p release; cd release
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j8
```

</details>

--------------------------------------------------------
# Build CPM Dromajo

CPM Dromajo is a fork of Dromajo from chips alliance. There is a branch 
which enables STF generation. The branch is based on dromajo SHA:f3c3112.

The process is to clone the fork and switch to the branch for all CPM
work.

Previously there were two maintained versions of Dromajo. Only CPM Dromajo
is needed now.

For reference: the original README for adding tracing to dromajo is in the 
olympia traces readme, $OLYMPIA/traces/README.md. This fork of dromajo has 
the proper stf patches already applied. 
```
cd $TOP
bash how-to/scripts/build_cpm_dromajo.sh
```

<details>
  <summary>Details: Building the CPM Dromajo step by step</summary>

```
cd $TOP
mkdir -p $TOOLS/bin

git clone git@github.com:Condor-Performance-Modeling/dromajo.git cpm.dromajo

cd $CPM_DROMAJO
git checkout jeffnye-gh/dromajo_stf_update

ln -s ../stf_lib

# The stf version
mkdir -p build; cd build
cmake ..
make -j8
cp dromajo $TOOLS/bin/cpm_dromajo

# The stf + simpoint version
cd ..
mkdir -p build-simpoint; cd build-simpoint
cmake .. -DSIMPOINT=On
make -j8
cp dromajo $TOOLS/bin/cpm_simpoint_dromajo
```

</details>

------------------------------------------------------------------------
# Build the Linux Kernel and File System

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

### Build and Install the linux kernel
```
cd $TOP
bash how-to/scripts/build_kernel.sh
```

<details>
  <summary>Details: Building the linux kernel step by step</summary>

```
cd $TOP
mkdir -p $TOOLS/riscv-linux
wget --no-check-certificate -nc https://git.kernel.org/torvalds/t/linux-5.8-rc4.tar.gz
tar -xf linux-5.8-rc4.tar.gz
make -C linux-5.8-rc4 ARCH=riscv defconfig
make -C linux-5.8-rc4 ARCH=riscv -j8
cp linux-5.8-rc4/arch/riscv/boot/Image $TOP/tools/riscv-linux/Image
```

</details>

### Build and Install the File System

You map be asked to entry the sudo password in the middle of this process.

```
cd $TOP
bash how-to/scripts/build_rootfs.sh
```

<details>
  <summary>Details: Building the file system step by step</summary>

Unfortunately the packages downloaded during make require manual patching.
Make is run three times so that the package download advances to the point
that the patches can be applied. 

This is not optimal, it is the current work around for issues in c-stack.c, and libfakeroot.c.
```
cd $TOP
wget --no-check-certificate https://github.com/buildroot/buildroot/archive/2020.05.1.tar.gz
tar xf 2020.05.1.tar.gz
cp $CPM_DROMAJO/run/config-buildroot-2020.05.1 buildroot-2020.05.1/.config
make -C buildroot-2020.05.1 -j8
```
The above make will fail, patch the c-stack file and make again
```
cp $PATCHES/c-stack.c ./buildroot-2020.05.1/output/build/host-m4-1.4.18/lib/c-stack.c
make -C buildroot-2020.05.1 -j8
```
The above will fail again, requires another patch and then make again
```
cp $PATCHES/libfakeroot.c ./buildroot-2020.05.1/output/build/host-fakeroot-1.20.2/libfakeroot.c
sudo make -C buildroot-2020.05.1 -j8

mkdir -p $TOP/tools/riscv-linux
cp $BUILDROOT/output/images/rootfs.cpio $TOP/tools/riscv-linux/rootfs.cpio
```
This final make is not expected to fail.
</details

------------------------------------------------------------------------
# Build OpenSBI

Open Supervisor Binary Interface

## PATH check
If you have done this previously you can skip the path check
<details>
  <summary> Details</summary>

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
</details>

## Download and compile OpenSBI

```
cd $TOP
bash how-to/scripts/build_opensbi.sh
```

<details>
  <summary>Build OpenSBI step by step</summary>

```
  cd $CONDOR_TOP
  mkdir -p $TOOLS/riscv-linux
  git clone https://github.com/riscv/opensbi.git
  cd opensbi
  make PLATFORM=generic -j8
  cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin $TOOLS/riscv-linux/fw_jump.bin
```

</details>

------------------------------------------------------------------------
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
  <summary>Build Spike step by step</summary>

```
cd $TOP
mkdir -p $TOOLS
git clone git@github.com:riscv/riscv-isa-sim.git
cd $SPIKE
mkdir -p build; cd build
../configure --prefix=$TOP/tools
make -j8
make install
```
</details>

<details>
  <summary>Build Whisper step by step</summary>
```
cd $TOP
mkdir -p $TOOLS/bin
git clone https://github.com/chipsalliance/VeeR-ISS.git whisper
cd $WHISPER
make -j8
cp build-Linux/whisper $TOOLS/bin
```
</details>

-----------------------------------------------------------------
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
$TOOLS/bin/cpm_dromajo --trace 0 --ctrlc --stf_no_priv_check --stf_trace example.stf cpm.boot.cfg
```

If you do not need STF trace generation the command line can be simplified
```
$TOOLS/bin/cpm_dromajo --ctrlc cpm.boot.cfg   # enable ctrl-c exit
$TOOLS/bin/cpm_dromajo --trace 0 cpm.boot.cfg # enable console tracing
```

------------------------------------------------------------------------
# Cloning the benchmark repo

The Condor benchmark repo uses a mix of submodules and copies of external
repos. The copies contain source modified from the original repo to enable
STF generation.

If you have a cloned benchmarks repo you do not need to clone it again.

The steps below tell you how to clone the repo. Once the repo has been
cloned there is a separate README for building and maintaining the suite.

```
cd $TOP
git clone git@github.com:Condor-Performance-Modeling/benchmarks.git
cd $BENCHMARKS
git submodule update --init --recursive
```

The benchmarks are built with a single make command. The bare metal versions
of the benchmarks are run at the same time.

```
cd $BENCHMARKS
make
```

The remaining instructions are in $BENCHMARKS/README.md.

These instructions document how to build the benchfs file system for linux 
benchmarking runs.

------------------------------------------------------------------------
# Patching SimPoint

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



<!--
------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------

I need to verify this section
------------------------------------------------------------------------
# Running programs on Dromajo

There are two processes, applications run under linux and bare metal
applications. In both cases the instrumentation process is the same.
Also in both cases the instrumentation is optional. Instrumentation
is only required for STF generation. STF generation is required to
drive Olympia, Dromajo will generate plain text traces or STF traces.

## Instrumenting programs for STF generation

For STF generation instrumentation macros are added to the source
file covering the region(s) of interest. Instrumentation macros are
only required for STF output. Dromajo will run uninstrumented 
binaries and still generate trace information.

The benchmarks repo contains the coremark benchmark that has 
instrumentation for STF generation.

An example, see this file $BENCHMARKS/riscv64/coremark/core_main.c

An include file and two macros are added to the file.

```
...
#include "trace\_macros.h"
...
MAIN\_RETURN\_TYPE main(int argc, char *argv[]) {
#endif

  START_TRACE; //JNYE HERE
...
  STOP_TRACE; //JNYE HERE
  return MAIN_RETURN_VAL;
}  

```
-->

<!-- I need to verify this section
### Adding the instrumented exe to the linux image and running Dromajo

This assumes you have previously built the benchmark suite. 

The commands below copy the target exe to the buildroot file system, 
compiles the file system and copies the resulting rootfs.cpio to 
Dromajo's run directory. Finally executing on Dromajo

```
  cd $TOP
  sudo rm -r $BUILDROOT/output/target/root/benchfs	
  sudo cp -r $BENCHMARKS/benchfs $BUILDROOT/output/target/root
  sudo make -C $BUILDROOT
  cp $BUILDROOT/output/images/rootfs.cpio $DROMAJO/run
  cd $DROMAJO/run
  ../build/dromajo --stf_trace my_trace.zstf boot.cfg
```
-->

<!-- sudo cp $BENCHMARKS/bin/coremark.riscv $BUILDROOT/output/target/sbin -->
<!-- some versions require --ctrlc, some do not accept it        -->
<!-- ../build/dromajo --ctrlc --stf_trace my_trace.zstf boot.cfg -->

<!--  I need to verify this section
</i>
Once linux has booted and login is complete, the application will be
found in /sbin. In this example the executable will be 
/sbin/coremark.riscv.

## Running a bare metal exe on Dromajo directly

The bare metal flow has fewer steps. The instrumentation methods are the
same. Once the code has been instrumented, copy the executable to the
Dromajo run directory and issue this command


### Running an instrumented exe on Dromajo for STF generation

```
  cp $BENCHMARKS/dhrystone.bare.riscv $DROMAJO/run
  cd $DROMAJO/run
  ../build/dromajo -stf_trace my_trace.zstf ./dhrystone.bare.riscv
```

### Running an uninstrumented exe on Dromajo for standard trace generation
-->

<!--
------------------------------------------------------------------------
# Build the STF analysis tools

Performance analysis uses a mix of Condor created tools and external tools.
A set of external tools is provided for STF analysis and data mining. I
have made changes to these tools for use by the CPM flow.

The original git repo is under the sparcians group, and is located here:
https://github.com/sparcians/stf_tools

The version used by CPM is located in a Condor managed repo. This repo
retains the original license etc.

To build the STF analysis tools:

```
	cd $TOP
```
--> 

<!-- This section needs to be updated
---------
# Using pipeline data views

A quick example of how to use pipeline data views.

## Prereqs

This assumes you have followed the instructions above for these steps.

- Install Miniconda on Ubuntu 22
- Install Map/Sparta on Ubuntu 22
- Install Map/Argos on Ubuntu 22
- Install riscv-perf-model on Ubuntu 22

## Create example core model

```
    cd $MAP/sparta/release/example/CoreModel
    make -j8
```

## Generate pipeline database

```
    cd $MAP/sparta/release/example/CoreModel
    ./sparta_core_example -i 1000 -z pipeout_
```

## View pipe output

### Pipeline data in single cycle view

```
    python3 ${MAP}/helios/pipeViewer/pipe_view/argos.py --database pipeout_ --layout-file cpu_layout.alf
```

### Pipeline data in multi-cycle view

```
    python3 ${MAP}/helios/pipeViewer/pipe_view/argos.py --database pipeout_ --layout-f
```
-->

<!-- This section needs clean up
--------------------------------------
# External references

External docs for running dromajo.

[Running baremetal and linux based apps on dromajo](https://github.com/chipsalliance/dromajo/blob/master/doc/setup.md)

[Running instrumented apps on dromajo to generate STF traces](https://github.com/riscv-software-src/riscv-perf-model/tree/master/traces)

--------------------------------------
# Perf flow to do list

For now this list is kept here. I might move it later.

- Install the binaries for the CPM flow for users in /tools

  - Also store these binaries in a hosted site that supports big private files

  - (The instructions above are still necessary for modeling developers)

- Fork olympia, map, stf_lib, spike, veer(whisper)

  - This is to improve stability when bringing up new versions
  
  - dromajo has already been forked, rename the repo to cpm.dromajo

  - Use these names cpm.dromajo, cpm.olympia, cpm.map, cpm.stf_lib, cpm.spike, cpm.whisper

  - With the forks I can eliminate the need for patched files

- Olympia seems to have an issue with running outside of it's build dir

  - This is in spite of what the command line options imply

  - Confirm/duplicate the issue, debug/fix/commit

- Merge latest riscv-perf-model commit with current

  - We use olympia from af3120490e96cc4e06735653e1bbe794aae3a111

  - Latest (2023.05.22) sha 2c6f628 in github does not build with MAP

      - This appears to be a bad checkin to the main repo

      - This commit adds a olympia conda environment, it seems broken

- It would be great if this could all be done with a script or two

  - Consider defining this so contractors could help out

- Consider supplying a model bashrc file to eliminate the need for setrc.sh

- Document how to build benchmark related items - tmp instrs below:
  - For coremark-pro
    - cd benchmarks/riscv-coremark-pro/coremark-pro
    - make TARGET=riscv64 TOOLS=$TOP/riscv64-unknown-linux-gnu clean
    - make TARGET=riscv64 TOOLS=$TOP/riscv64-unknown-linux-gnu build
    - cp -r builds/riscv64/riscv-gcc64/bin ../../benchfs/coremark-pro/bin/
  - for benchfs
    - cd $TOP
    - sudo rm -rf buildroot-2020.05.1/output/target/root/benchfs
    - sudo cp -r benchmarks/benchfs buildroot-2020.05.1/output/target/root
    - sudo make -C buildroot-2020.05.1
  - for dromajo
    - cd dromajo/run
    - cp ../../buildroot-2020.05.1/output/images/rootfs.cpio .
    - ../build/dromajo --stf_trace coremark-pro.stf boot.cfg
    - root/root
    - $> cd benchfs
    - $> ./run.coremark-pro.sh cjpeg    (done)
    - <move stf file>
    - $> ./run.coremark-pro.sh core     (done) alt   <deleted>
    - <move stf file>
    - $> ./run.coremark-pro.sh linear   (done) alt.2 <deleted>
    - <move stf file>
    - $> ./run.coremark-pro.sh loops    (needs restart alt.3 file name already ...loops)
    - <move stf file>
    - $> ./run.coremark-pro.sh nnet     (done)
    - <move stf file>
    - $> ./run.coremark-pro.sh parser   (done) 
    - <move stf file>
    - $> ./run.coremark-pro.sh radix2   (done) 
    - <move stf file>
    - $> ./run.coremark-pro.sh sha      (done)
    - <move stf file>
    - $> ./run.coremark-pro.sh zip      (done)
    - <move stf file>

-->
