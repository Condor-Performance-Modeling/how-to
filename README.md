# Readme 

# Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is a github organization. 

CPM contains a number of repo's used by Condor. 
Condor-Performance-Modeling/how-to contains documentation, patches and 
support scripts. The steps that follow document building the Condor 
perf modeling environment and provide instructions on how to use it.

--------------------------------------
# ToC

1. [Boot strapping the environment](#boot-strapping-the-environment)

1. [Clone the CPM repos](#clone-the-cpm-repos)

1. [Build/Install MAP](#build-install-map)

1. [Build/Install Olympia](#build-install-olympia)

1. [Build STF Lib](#build-stf-lib)

1. [Build CPM Dromajo](#build-cpm-dromajo)

1. [Build fast Dromajo](#build-fast-dromajo)

1. [Build the Linux kernel and file system](#build-the-linux-kernel-and-file-system)

1. [Build OpenSBI](#build-opensbi)

1. [Boot Linux on the Dromajo(s)](#boot-linux-on-the-dromajos)

1. [Build Spike](#build-spike)

1. [Build Whisper](#build-whisper)

1. [Cloning the benchmark repo](#cloning-the-benchmark-repo)

<!--
1. [Build the analysis tool suite](#build-the-analysis-tool-suite)
1. [Build the benchmark suite](#build-the-benchmark-suite)
1. [Running programs on CPM Dromajo](#running-programs-on-cpm-dromajo)
1. [Perf flow to-do list](#perf-flow-to-do-list)
1. [Using pipeline data views](#using-pipeline-data-views)
-->

--------------------------------------
# Boot strapping the environment

Presumably you are reading this how-to from the web or a local copy.  This
section contains instructions to boot strap the Condor Performance Modeling 
(CPM) environment.

## Linux, C-AWS and VCAD environments

In order to proceed you need a linux machine with git installed. In 
production this machine would be part of the C-AWS domain. In development
local linux machines are supported. 

You must have an account with C-AWS, you must be registered with CPM.

You will want to have your ssh keys installed and registered with GitHub 
and ssh-agent. 

If you have done this already you can skip this section.

<details>
  <summary>Details</summary>


There are two* Ubuntu environments at present, Condor AWS aka C-AWS, and 
VCAD. C-AWS is Condor managed, with assistance from OutServ. 

These instructions are not for the VCAD environment. See Jeff if 
you are creating a CPM environment in VCAD.

*Caveat: You can also use these instructions on a local machine not under 
C-AWS. The long term solution is to use your C-AWS account and resources. 

## Become member of Github CPM organization
You must be a member of Condor Performance Modeling (CPM) GitHub 
organization before you can access the private repos in this list.

Send me your account name via slack or email. I will send you back a
note when I have added your account to CPM.

## Request an account on C-AWS
You can skip this step short term, if you are running on a local linux machine.

Send me a slack or email telling me you need a C-AWS account. I will send
you back the instructions on how to get an account and then how to access
it.  I'm doing it this way to avoid exposing the process, sorry.

## Create and register your ssh keys.

Once you have access to a linux machine generate your public SSH keys. You will
add this key to your github account. You need to do this for each machine that
will clone or push to the CPM repo.

### Create your keys

```
  aw01ut01: cd $HOME
  aw01ut01: ssh-keygen

  Enter file in which to save the key (some/path): 
  Enter passphrase (empty for no passphrase): <your passphrase>
```

<b>Do not use an empty passphrase. </b>

```
  Enter same passphrase again: <your passphrase>

  aw01ut01> chmod 700 ~/.ssh
  aw01ut01> chmod 600 ~/.ssh/*
```

You will use your passphrase in place of a password when cloning and pushing.

### Add your keys to ssh-agent

```
  eval `ssh-agent`
  ssh-add $HOME/.ssh/id_rsa

```

More details can be found [GITHUB](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) and [ATLASSIAN](https://www.atlassian.com/git/tutorials/git-ssh)

### Register your keys with github

Follow the instructions [GITHUB-2](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

Note your ssh public key is in this file $HOME/.ssh/id_rsa.pub. The contents
of this file are pasted at step 7.
</details>

# Clone the CPM repos

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
mkdir condor
cd condor

git clone git@github.com:Condor-Performance-Modeling/how-to.git

git clone git@github.com:Condor-Performance-Modeling/utils.git

git clone git@github.com:Condor-Performance-Modeling/benchmarks.git
cd $BENCHMARKS
git submodule update --init --recursive
```

## Setup the build environment variables

I have moved the instructions to a separate file because the instructions 
are shared with other build instructions.

The new location is [LINK](./SET_LOCAL_ENV.md)

If you do not want the details you can safely just do this:

```
cd condor
source how-to/env/setuprc.sh
```

## Install the Ubuntu collateral

This will be done once for everyone. If you are not setting up a new machine 
you can skip this step.

<details>
  <summary>Details</summary>

Install the Ubuntu support packages:

```
  sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev
  sudo apt install rapidjson-dev xz-utils autoconf automake autotools-dev 
  sudo apt install curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk 
  sudo apt install build-essential bison flex texinfo gperf libtool patchutils 
  sudo apt install bc zlib1g-dev libexpat-dev ninja-build device-tree-compiler
  sudo apt install libboost-all-dev  libsqlite3-dev libhdf5-serial-dev
  sudo apt install libzstd-dev gcc-multilib qtbase5-dev qt5-qmake pkg-config
  sudo apt install clang-tidy npm nodejs pip

  sudo pip install flask docopt path_and_address grip
```

All in one line for easy cut/paste:

```
sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev rapidjson-dev xz-utils autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build device-tree-compiler libboost-all-dev libsqlite3-dev libhdf5-serial-dev libzstd-dev gcc-multilib qt5-dev qt5-qmake pkg-config clang-tidy npm nodejs
```
</details>

## Install RISCV GNU Tool Chain

Note: For now ask me where these tools are kept, once Outserv is done 
these will have a fixed home, e.g. /usr/local

<details>
  <summary>Details</summary>

Some estimates say ~7GB of space is needed for these tools.

There are pre-built versions of the bare metal and linux tools. See
Jeff to get the link. These versions can save hours of compile time.


<!-- For the DIY-ers see this page: [LINK](./CROSS_TOOL_CHAIN.md) -->
<!-- I have not checked this in a while, commented until i can check it -->

Example:
```
  cd $TOP
  ln -s /usr/local/riscv64-unknown-elf
  ln -s /usr/local/riscv64-unknown-linux-gnu
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
  <summary>Details</summary>

In accepting the license:

- I am using the default install location
- I am allowing the installer to run conda init
- I am allowing the installer to modify my .bashrc
- I manually move the conda init lines from .bashrc to my .bashrc.private

The instructions tell you how to disable miniconda activation at 
startup

- conda config --set auto_activate_base false

- I am not executing this command


```
cd $TOP

wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

sh ./Miniconda3-latest-Linux-x86_64.sh

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


## Install the Miniconda components

```
cd <workspace>/condor
source how-to/env/setuprc.sh

conda activate
conda install -c conda-forge jq
Proceed ([y]/n)? y
conda install -c conda-forge yq
Proceed ([y]/n)? y
```

</details>

----------------------------------------------------------
# Build/Install MAP

This section builds and installs Map and it's components: Sparta and Sparta's 
conda environment, and Helios/Argos

If you have previously install MAP you will have a MAP Conda environment
in you home directory and you may receive the "prefix already exists"
message when creating the conda environment. This is benign.

```
  cd $TOP
  git clone https://github.com/sparcians/map.git
  cd $MAP
  ./scripts/create_conda_env.sh sparta dev
  conda activate sparta
```
Your prompt should now start with (sparta)

```
  cd $MAP/sparta; mkdir release; cd release
  cmake .. -DCMAKE_BUILD_TYPE=Release
  make -j8
  cmake --install . --prefix $CONDA_PREFIX
  cd $MAP/helios; mkdir release; cd release
  cmake -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta ..
  make -j8
  cmake --install . --prefix $CONDA_PREFIX
```

---------

# Build/Install Olympia

```
  cd $TOP
  mkdir -p tools/bin
  git clone --recursive https://@github.com/riscv-software-src/riscv-perf-model.git

  cd $OLYMPIA
  mkdir -p release; cd release
  cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
  make -j8
  cmake --install . --prefix $CONDA_PREFIX
  cp olympia $TOP/tools/bin/cam
```

---------

# Build STF Lib

STF is a library supporting the Simulation Trace Format.

```
  cd $TOP
  git clone https://github.com/sparcians/stf_lib.git
  cd stf_lib
  mkdir -p release; cd release
  cmake -DCMAKE_BUILD_TYPE=Release ..
  make -j8
```

----------------------------------
# Build CPM Dromajo

CPM Dromajo is a patched version of Dromajo enabled for generating STF traces.
Tracing adds overhead to Dromajo execution. If you do not need STF trace 
generation the unpatched dromajo will perform much better. See 
'Build Fast Dromajo'

For reference: the original README for adding tracing to dromajo is in the 
olympia traces readme, $OLYMPIA/traces/README.md. This fork of dromajo has 
the proper stf patches already applied. 
```
  cd $TOP
  mkdir -p $TOP/tools/bin $TOP/tools/lib
  git clone git@github.com:Condor-Performance-Modeling/dromajo.git cpm.dromajo
  cd $CPM_DROMAJO
  ln -s ../stf_lib
  mkdir -p build; cd build
  cmake .. 
  make -j8
  mkdir -p $TOP/tools/bin $TOP/tools/lib
  cp dromajo $TOP/tools/bin/cpm.dromajo
  cp libdromajo_cosim.a $TOP/tools/lib/libcpm_dromajo_cosim.a
```

Note: the cmake control file for dromajo does not include a complete INSTALL
target. The install is done by hand. Also note the renames: cpm.dromajo.

----------------------------------
# Build Fast Dromajo

This set is optional if you do not need STF generation.
<details>
  <summary> Details</summary>

This verision of Dromajo is fast but does not include STF trace generation
support. 

The optimizations which make Dromajo fast are structurally present in the
instruction decode and execute loop. With time I will create patch files
that enable/disable tracing with in a single build and retain the performance
when tracing is not enabled.

For now there are two distinct builds.
```
  git clone https://github.com/chipsalliance/dromajo
  cd $DROMAJO
  ln -s ../stf_lib
  mkdir -p build; cd build
  cmake ..
  make -j8
  mkdir -p $TOP/tools/bin $TOP/tools/lib
  cp dromajo $TOP/tools/bin/dromajo
  cp libdromajo_cosim.a $TOP/tools/lib/libdromajo_cosim.a
```
</details>

------------------------------------------------------------------------
# Build the Linux kernel and file system

### PATH check
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

### WGET and build kernel
```
  cd $TOP
  wget --no-check-certificate -nc https://git.kernel.org/torvalds/t/linux-5.8-rc4.tar.gz
  tar -xf linux-5.8-rc4.tar.gz
  make -C linux-5.8-rc4 ARCH=riscv defconfig
  make -C linux-5.8-rc4 ARCH=riscv -j8
  mkdir -p $TOP/tools/riscv-linux
  cp linux-5.8-rc4/arch/riscv/boot/Image $TOP/tools/riscv-linux/Image
```

### WGET and build the file system

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

------------------------------------------------------------------------
# Build OpenSBI
### PATH check
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

### Download and compile OpenSBI
```
  cd $TOP
  git clone https://github.com/riscv/opensbi.git
  cd opensbi
  make PLATFORM=generic -j8
  mkdir -p $TOP/tools/riscv-linux
  cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin $TOP/tools/riscv-linux/fw_jump.bin
```
------------------------------------------------------------------------
# Boot Linux on the Dromajo(s)

The above steps create the necessary collateral to boot linux on either 
Dromajo version.

If you need STF generation use $CPM_DROMAJO, else $DROMAJO is the faster
version.

login is root, password is root for both versions.

## Boot linux - CPM DROMAJO 
Copy the images/etc from previous steps to the CPM Dromajo run directory.
```
cp $TOOLS/riscv-linux/* $CPM_DROMAJO/run
cp $PATCHES/cpm.boot.cfg  $CPM_DROMAJO/run
cd $CPM_DROMAJO/run
$TOP/tools/bin/cpm.dromajo --stf_trace example.stf cpm.boot.cfg
```

<!--
```
  cd $CPM_DROMAJO/run
  cp $BUILDROOT/output/images/rootfs.cpio .
  cp $KERNEL/arch/riscv/boot/Image .
  cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin .
  cp $PATCHES/cpm.boot.cfg .
  ../build/dromajo --stf_trace example.stf --ctrlc cpm.boot.cfg
```
-->

Control C exit is enabled in this version.

## Boot linux - Fast DROMAJO 
Copy the images/etc from the BuildRoot step to the Fast Dromajo run directory.

```
cp $TOOLS/riscv-linux/* $DROMAJO/run
cp $PATCHES/fast.boot.cfg  $DROMAJO/run
cd $DROMAJO/run
$TOP/tools/bin/dromajo --ctrlc fast.boot.cfg
```
<!--
```
  cd $DROMAJO/run
  cp $BUILDROOT/output/images/rootfs.cpio .
  cp $KERNEL/arch/riscv/boot/Image .
  cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin .
  cp $PATCHES/fast.boot.cfg .
  ../build/dromajo --ctrlc fast.boot.cfg
```
-->
--ctrlc allows Control-C to exit the simulator. Without --ctrlc use kill
to terminate eh simulator.

------------------------------------------------------------------------
# Build Spike

## Exit Conda

You must deactivate the conda environment before compiling Spike. Once
to exit the sparta environment, once again to exit the base conda 
environment. Your prompt should not show (base) or (sparta) when you have 
successfully deactivated the environments.

```
  conda deactivate     # leave sparta
  conda deactivate     # leave base
```
<!--
  this may no longer be necessary
  cd <workspace>/condor
  source how-to/env/setuprc.sh
-->

## Build Spike

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

------------------------------------------------------------------------
# Build Whisper

## Exit Conda

If you have exited the conda environments above you can proceed with the
build steps.

<details>
  <summary>Details</summary>

You must deactivate the conda environment before compiling Spike.
Once to exit the sparta environment, once again to exit the base conda 
environment. Your prompt should not show (base) or (sparta) when you have 
successfully deactivated the environments.

```
  conda deactivate     # sparta
  conda deactivate     # base
```
</details>

<!--
  cd <workspace>/condor
  source how-to/env/setuprc.sh
-->

Proceed with the build.

```
    cd $TOP
    mkdir -p $TOOLS/bin
    git clone https://github.com/chipsalliance/VeeR-ISS.git whisper
    cd $WHISPER
    make -j8
    cp build-Linux/whisper $TOOLS/bin
```

------------------------------------------------------------------------
------------------------------------------------------------------------
# Cloning the benchmark repo

The Condor benchmark repo uses a mix of submodules and copies of external
repos. The copies contain source modified from the original repo to enable
STF generation.

The steps below tell you how to clone the repo. Once the repo has been
cloned there is a separate README for building and maintaining the suite.

```
cd $TOP
git clone git@github.com:Condor-Performance-Modeling/benchmarks.git
cd $BENCHMARKS
git submodule update --init --recursive
```

The remaining instructions are now available in benchmarks/README.md.

<!-- 
I need to fix this section
------------------------------------------------------------------------
# Build the benchmark suite

The Condor benchmark repo uses a mix of submodules and copies of external
repos. The copies contain source modified from the original repo to enable
STF generation.

## Cloning and build the benchmark repo

```
cd $TOP
git clone git@github.com:Condor-Performance-Modeling/benchmarks.git
cd $BENCHMARKS
git submodule update --init --recursive
export RISCV=$RV_BAREMETAL_TOOLS
make 

```

The results will be in bin.

## Building riscv-tests

Note this adds the baremetal tool path to you environment. Previously
the linux based tools where added to your path.

But otherwise if you have done this before you do not need to do it again.

Check that riscv64-unknown-elf-gcc is in your path.

```
which riscv64-unknown-elf-gcc
```

If not export to your PATH variable as shown.

```
export PATH=$RV_BAREMETAL_TOOLS/bin:$PATH
```

```
cd $BENCHMARKS/riscv-tests-src
autoconf
./configure --prefix=$BENCHMARKS/riscv-tests
make
make install
```

Binaries (.riscv) and object dump files (.dump) will be placed
in $BENCHMARKS/riscv-tests/share/riscv-tests/benchmarks and in
$BENCHMARKS/riscv-tests/share/riscv-tests/isa for the benchmark
and compliance suites.

## Running the instrumented baremetal benchmarks

```
cd $BENCHMARKS/instrumented
make
```

## Status of benchmarks

We keep track of the status of benchmarks.  Long term this will be
done through a confluence page, for now I"m doing this in a side
.md file. 

This is the current [LINK](./BENCHSTATUS.md).
-->

<!-- I need to verify this section
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
