# Readme 

<b> THIS IS INCOMPLETE NOT READY FOR USE </b>

There are two environments, called From-Scratch and Incremental. 

This is the instruction set for the Incremental environment. 

## From-Scratch

The From-Scratch environment was the version of the environment  created
prior to the transition to C-AWS.

The From-Scratch environment builds all tools and packages locally, with
few exceptions. From-Scratch is primarily used by package maintainers. The
instructions for From-Scratch are in $TOP/how-to/README.md

## Incremental

The Incremental environment uses pre-installed versions of all but the
targeted tool set. For example if you are developing models for CAM and
are not modifying Dromajo you can use the installed version of Dromajo
and save building it from scratch.

The distinction between Incremental and From-Scratch is not crisp, it
is possible to move between the two by replacing links to the installed
tools with clones of the appropriate repo.

A fully incremental environment is less effort to setup. Most of the setup is
handled in a single C-AWS specific script.

## Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is our github organization. It is 
described in how-to/README.md. CPM may be referenced below.

--------------------------------------
# ToC

1. [Boot strapping the environment](#boot-strapping-the-environment)

1. [Clone the CPM repos](#clone-the-cpm-repos)

1. [Build/Install MAP](#build-install-map)

1. [Build/Install CAM](#build-install-cam)

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
# Prequisites

Presumably you are reading this how-to from the web or a local copy.  This
section contains instructions to configure an Incremental build environment.

You must be logged into your linux account on C-AWS. I assume interactive1
is being used. Please do not do this on gui1.

# Setup shell RC file

FIXME: any users of other shells can contribute their instructions

## For bash

Add this to the end of your .bashrc file:

```
if [ -f ~/.bashrc_user ]; then
    . ~/.bashrc_user
fi
```

Add this to your .bashrc_user file

```
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/tools/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/tools/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/tools/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/tools/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
```

## Recommended for bash

I also add these to the beginning of my bashrc_user file. YMMV.

```
export GIT_EDITOR=vim
stty   sane
export EDITOR=vim
export BASH_ENV=/home/$USER/.bashrc

export WS=/data/users/$USER
export EXTT=/exttools
export TOOLS=/tools

shopt -s checkwinsize
shopt -s histappend

HISTCONTROL=ignoredups:erasedups
HISTSIZE=2000
HISTFILESIZE=10000

```
# Create a work area and (optional) grab the how-to repo

It is useful to have a local copy of the How-To repo. It is not strictly 
required.

Here is one way to do this:

```
cd /data/users
mkdir -p <userid>/condor
cd <userid>/condor

<optional> git clone git@github.com:Condor-Performance-Modeling/how-to.git
```

# Execute the master setup script

```
cd /data/users/$USER
bash /tools/scripts/incremental.sh
```

# Install RISCV GNU Tool Chain

These tools are preinstalled in /tools. Create links to these tools in
your work area.

```
  cd $TOP
  ln -s /tools/riscv64-unknown-elf
  ln -s /tools/riscv64-unknown-linux-gnu
```
</details>

## Activate Miniconda

Miniconda package manager is used by Sparcians. There is a preinstalled
version of miniconda in /tools. You need support in your bashrc file
and you will need to activate it.

Bashrc instructions are above. To activate the environment simply issue:

```
conda activate
```

Your prompt should now have the "(base)" prefix.

---------
# Remainder of the setup

Create a link to the preinstalled MAP/Sparta tool set.

```
  cd $TOP
  ln -s /tools/map
```
---------

# Build/Install CAM
This builds the Condor fork of olympia (Cuzco Architecture Model). The build
process is similar to Olympia.

```
  cd $TOP
  mkdir -p tools/bin
  git clone git@github.com:Condor-Performance-Modeling/cam.git

  cd $CAM
  mkdir -p release; cd release
  cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
  make -j8
  cmake --install . --prefix $CONDA_PREFIX
  cp olympia $TOP/tools/bin/cam
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
  cp olympia $TOP/tools/bin/olympia
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
