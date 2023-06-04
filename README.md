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

1. [Set local environment variables](#set-local-environment-variables)

1. [Install the Ubuntu collateral](#install-the-ubuntu-collateral)

1. [Install riscv gnu tool chain](#install-riscv-gnu-tool-chain)
    
1. [Build STF Lib](#build-stf-lib)

1. [Install MAP](#install-map)

    1. [Install Miniconda](#install-miniconda)
    1. [Install Conda components](#install-conda-components)
    1. [Build and install Map](#build-and-install-map)
    1. [Build and install Helios/Argos](#build-and-install-helios-argos)

1. [Install Olympia](#install-olympia)

1. [Using pipeline data views](#using-pipeline-data-views)

1. [Build Dromajo](#build-dromajo)

1. [Build the Linux kernel](#build-the-linux-kernel)

1. [Build the Linux file system](#build-the-linux-file-system)

1. [Boot Linux on Dromajo](#boot-linux-on-dromajo)

1. [Build Spike](#build-spike)

1. [Build Whisper](#build-whisper)

1. [Build the benchmark suite](#build-the-benchmark-suite)

1. [Running programs on Dromajo](#running-programs-on-dromajo)

1. [Perf flow to-do list](#perf-flow-to-do-list)

--------------------------------------
# Boot strapping the environment

Presumably you are reading this how-to from the web or a local copy. The
instructions in subsequent sections use the paths and environment
variables created here. Follow these steps:

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
```

--------------------------------------
# Set local environment variables

I have moved the instructions to a separate file because the instructions 
are shared with other build instructions.

The new location is [LINK](./SET_LOCAL_ENV.md)

Without the details, you can just do this:

```
cd condor
source how-to/env/setupenv.sh
```

--------------------------------------
# Install the Ubuntu collateral

Install the Ubuntu support packages:

```
  sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev
  sudo apt install rapidjson-dev xz-utils autoconf automake autotools-dev 
  sudo apt install curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk 
  sudo apt install build-essential bison flex texinfo gperf libtool patchutils 
  sudo apt install bc zlib1g-dev libexpat-dev ninja-build device-tree-compiler
  sudo apt install libboost-all-dev  libsqlite3-dev libhdf5-serial-dev
  sudo apt install libzstd-dev gcc-multilib qt5-dev qt5-qmake pkg-config
```

All in one line for easy cut/paste:

```
sudo apt install cmake sqlite doxygen hdf5-tools h5utils libyaml-cpp-dev rapidjson-dev xz-utils autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build device-tree-compiler libboost-all-dev libsqlite3-dev libhdf5-serial-dev libzstd-dev gcc-multilib qt5-dev qt5-qmake pkg-config
```

--------------------------------------
# Install RISCV GNU Tool Chain

Some estimates say ~7GB of space is needed for these tools.

There are pre-built versions of the bare metal and linux tools. See
Jeff to get the link. These versions can save hours of compile time.

For the DIY-ers see this page: [LINK](./CROSS_TOOL_CHAIN.md)

---------

# Build STF Lib

STF is a library supporting the Simulation Trace Format.

```
    cd $TOP
    git clone https://github.com/sparcians/stf_lib.git
    cd stf_lib
    git checkout 742037fb80bfe97cb27d7063e24f9bb60b0144f3
    mkdir -p release; cd release
    cmake -DCMAKE_BUILD_TYPE=Release ..
    make -j8
```

----------------------------------------------------------
# Install MAP

This section builds and installs Map and it's components, the conda
environment, Sparta, and Helios/Argos

## Install Miniconda

Miniconda package manager is used by Sparcians.

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
cd $WGETTMP
wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
sh ./Miniconda3-latest-Linux-x86_64.sh
```

<i> Make sure you move the added .bashrc lines to a private rc file if 
you are in a managed environment.</i>

## Active conda

Start a new shell to activate conda, your prompt should look similar to this:

```
(base) jeff@reynaldo:~/Development/condor
```

Then re-source the CPM environment script.

```
cd <workspace>/condor
source how-to/env/setuprc.sh
```

----------------------------------------------------------
## Clone map and it's components

```
    cd $TOP
    git clone https://github.com/sparcians/map.git
    cd map
    previous: git checkout 277037f3cc2594df0ba04e3ad92d41d95e9ea3f9
    broken:   git checkout map_v2
```

## Patch the source files (for Olympia)

<b>FIXME: Create actual patch files, for now copy the pre-edited files</b>

If you are building Olympia (riscv-perf-model) then copy over these two files.

```
    cd $MAP/sparta
    cp $PATCHES/TreeNodeExtensions.cpp $MAP/sparta/src/TreeNodeExtensions.cpp
    cp $PATCHES/TreeNodeExtensions.hpp $MAP/sparta/sparta/simulation/TreeNodeExtensions.hpp
```

## Install Conda components

If not already active, activate the conda environment

```
  conda activate
```

Install the conda packages, activate the sparta conda environment

```
    cd $MAP
    conda install -c conda-forge jq 
    conda install -c conda-forge yq
    ./scripts/create_conda_env.sh sparta dev
```

<!-- during this the following warnings are issues, FIXME check into these
are they harmless? 
WARNING:conda_build.render:Returning non-final recipe for map-map_v1.1.0-4_h1234567_g277037f3; one or more dependencies was unsatisfiable:                      
Build: llvm-tools, clangxx, boost, python, doxygen, clang, rsync, cppcheck      
WARNING:conda_build.render:Build: llvm-tools, clangxx, boost, python, doxygen, clang, rsync, cppcheck                                                           
Host: hdf5, boost-cpp, python
WARNING:conda_build.render:Host: hdf5, boost-cpp, python
-->

Now active the sparta environment

```
    conda activate sparta
```

<!--
#    cd $(git rev-parse --show-toplevel);
#    mkdir -p release; cd release
#    mkdir helios
-->

A successfully activated sparta/conda environment will change your 
prompt to (sparta):

```
(sparta) jeff@reynaldo:~/Development/condor/map
```

<!--
For future reference the commands to activate and deactivate are shown. These can be issued in any directory.
```
> conda activate sparta                                                   
> conda deactivate 
```
-->

## Build map and sparta

```
    conda activate sparta
    cd $MAP/sparta
    mkdir release; cd release
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j8
    cmake --install . --prefix $CONDA_PREFIX
```

CONDA_PREFIX is set during conda activation.

---------

## Build Helios and Argos

Argos is a python pipe viewer for trace based performance models. It is 
variously named, even within the repo, as Helio, Argos, pipeViewer, 
or pipe_view. 

The python script is argos.py, the path is $MAP/helios/pipeViewer/argos.py.

Your terminal should have an active sparta/conda dev environment.

```
    cd $MAP
    conda activate sparta
    cd $MAP/helios
    mkdir -p release; cd release
    cp $PATCHES/transactiondb_CMakeLists.txt ../pipeViewer/transactiondb/CMakeLists.txt
    cp $PATCHES/transactionsearch_CMakeLists.txt ../pipeViewer/transactionsearch/CMakeLists.txt
    cmake -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta ..
    make -j8
    cmake --install . --prefix $CONDA_PREFIX
    mkdir -p $MAP/release/helios
    cd $MAP/release/helios
    cp -r ../../helios/release/pipeViewer .
```
---------
# Install Olympia

riscv-perf-model aka Olympia. Olympia is a trace driven OOO 
performance model.  The Olympia model is intended as a template,
micro-architecture modeling has not completed.

Olympia does have some interesting capabilities in terms of trace input formats in [STF](https://github.com/sparcians/stf_spec) and [JSON](https://github.com/riscv-software-src/riscv-perf-model/tree/master/traces#json-inputs).

The Condor Architecture Model (CAM) will be a fork of
Olympia. Instructions will be added here when that fork occurs.

## Clone the repo

There are errors in map/Sparta source files when compiling for Olympia.  
Make the source file changes described above (TreeNodeExtensions.hpp/cpp).

<!-- There is also an error in Dispatch.hpp, see below. -->

```
    cd $TOP
    git clone --recursive https://@github.com/riscv-software-src/riscv-perf-model.git
    git checkout af3120490e96cc4e06735653e1bbe794aae3a111
```

<!--    git af3120490e96cc4e06735653e1bbe794aae3a111 -->

## Build the Olympia performance model.

```
    cd $OLYMPIA
    mkdir -p release; cd release
    cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
    # Select the build level
    make -j8           # build everything
    #make -j8 olympia  # build the simulator only
    #make -j8 regress  # as it says
    mkdir -p $TOP/tools/bin
    cp olympia $TOP/tools/bin/cam
```

----------------------------------
# Build Dromajo

The original README for adding tracing to dromajo is in the olympia 
traces readme.  $OLYMPIA/traces/README.md

## Clone dromajo, link to STF LIB

<!-- 
This is old info, kept for reference
OLD FIXME: I need to re-create the patch, there was a fix for console io 
performance in dromajo, so the checksum below is no longer used, and 
I need to verify that the patch still works.
The issue is the trace macros are not detected. The perf improvement 
executes instructions in batches of 1000. I believe in this scheme the
trace macro is not detected. This is a theory.
-->

This fork of dromajo has the proper stf patches already applied. 

```
    cd $TOP
    git clone git@github.com:Condor-Performance-Modeling/dromajo.git
    cd dromajo
    ln -s ../stf_lib
```

<!-- The original repo is here, above is our fork                  -->
<!-- A patch is supplied to modify Dromajo to generate STF traces. -->
<!-- These steps clone the repo, checkout the known compatible     -->
<!-- commit and patch the source.                                  -->
<!-- git clone https://github.com/chipsalliance/dromajo            -->
<!-- git checkout 86125b31                                         -->
<!-- git apply $PATCHES/dromajo_stf_lib.patch                      -->
<!-- ln -s ../stf_lib                                              -->
<!-- fix the CMakelists.txt file c++17 line 53                     -->

<!-- OLD No longer necessary with fork, FIXME: rename repo to cpm.dromajo

## Correct cmake files 

stf_lib/stf-config.cmake must be edited for correct compile.

```
    cd $DROMAJO
    vi $OLYMPIA/stf_lib/cmake/stf-config.cmake
    change line ~14 to (remove _GLOBAL):
        set_target_properties(Threads::Threads PROPERTIES IMPORTED TRUE)
    vi ./CMakeLists.txt
    change line ~53 to (change std to ++17)
        -std=c++17
```
-->

## Compile dromajo

```
    cd $DROMAJO
    mkdir -p build; cd build
    # FIXME: this is an uglier than normal hack
    cp $OLYMPIA/traces/stf_trace_gen/trace_macros.h $TOP
    cmake ..
    make -j8
    mkdir -p $TOP/tools/bin
    cp dromajo $TOP/tools/bin
```

<!-- OLD No longer necessary with fork, FIXME: rename repo to cpm.dromajo

## Verify patch

Check if patch worked, dromajo should have the --stf_trace option

```
    cd $DROMAJO/build
    ./dromajo | grep stf_trace
    console:
        --stf_trace <filename>  Dump an STF trace
```
-->

------------------------------------------------------------------------
# Build the Linux kernel
## Check path to the linux gnu tool chain

Check that riscv64-unknown-linux-gnu-gcc is in your path.

```
which riscv64-unknown-linux-gnu-gcc
```

If not, add it to your PATH variable as shown.

```
export PATH=$RV_LINUX_TOOLS/bin:$PATH
```

### Get and build kernel

```
    cd $TOP
    export CROSS_COMPILE=riscv64-unknown-linux-gnu-
    wget --no-check-certificate -nc https://git.kernel.org/torvalds/t/linux-5.8-rc4.tar.gz
    tar -xf linux-5.8-rc4.tar.gz
    make -C linux-5.8-rc4 ARCH=riscv defconfig
    make -C linux-5.8-rc4 ARCH=riscv -j8
```

------------------------------------------------------------------------
# Build the Linux file system

## Check path to the linux gnu tool chain

If you have already done this step previously you do not need to do it again.

Check that riscv64-unknown-linux-gnu-gcc is in your path.

```
which riscv64-unknown-linux-gnu-gcc
```

If not export to your PATH variable as shown.

```
export PATH=$RV_LINUX_TOOLS/bin:$PATH
```

## Create buildroot image
```
    cd $TOP
    wget --no-check-certificate https://github.com/buildroot/buildroot/archive/2020.05.1.tar.gz
    tar xf 2020.05.1.tar.gz
    cp $DROMAJO/run/config-buildroot-2020.05.1 buildroot-2020.05.1/.config
    make -C buildroot-2020.05.1
    (this may fail, if so copy this file)
    cp $PATCHES/c-stack.c ./buildroot-2020.05.1/output/build/host-m4-1.4.18/lib/c-stack.c
    make -C buildroot-2020.05.1
    (this may fail, if so copy this file)
    cp $PATCHES/libfakeroot.c ./buildroot-2020.05.1/output/build/host-fakeroot-1.20.2/libfakeroot.c
    sudo make -C buildroot-2020.05.1
    (this is expected to finish without error)
```
------------------------------------------------------------------------
# Build OpenSBI

## Check path to the linux gnu tool chain

If you have already done this step previously you do not need to do it again.

Check that riscv64-unknown-linux-gnu-gcc is in your path.

```
which riscv64-unknown-linux-gnu-gcc
```

If not export to your PATH variable as shown.

```
export PATH=$RV_LINUX_TOOLS/bin:$PATH
```

## Download and compile OpenSBI

```
    cd $TOP
    export CROSS_COMPILE=riscv64-unknown-linux-gnu-
    git clone https://github.com/riscv/opensbi.git
    cd opensbi
    git checkout tags/v0.8 -b temp2
    # works too: git checkout 7be75f519f7705367030258c4410d9ff9ea24a6f -b temp
    make PLATFORM=generic 
```

------------------------------------------------------------------------
# Boot Linux on Dromajo

You must have previously installed the riscv gnu tool chain.
See [Install riscv gnu tool chain](#install-riscv-gnu-tool-chain)

This assumes you have built the pre-reqs, opensbi, linux kernel and linux 
file system. See instructions above.

## Copy collateral and boot linux
Copy the images/etc from the BuildRoot step to the Dromajo run directory.

```
    cd $DROMAJO/run
    cp $BUILDROOT/output/images/rootfs.cpio .
    cp $KERNEL/arch/riscv/boot/Image .
    cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin .
    ../build/dromajo boot.cfg
```
login is root, password is root

Use Control-C or 'kill <pid>' to exit dromajo.

------------------------------------------------------------------------
# Build Spike

You must deactivate the conda environment before compiling Spike. Once
to exit the sparta env, once again to exit the base conda environment. Your
prompt should not show (base) or (sparta) when you have successfully
deactivated the environments.

```
  conda deactivate     # sparta
  conda deactivate     # base
  cd <workspace>/condor
  source how-to/env/setuprc.sh
```

Proceed with the build.

```
    cd $TOP
    git clone git@github.com:riscv/riscv-isa-sim.git
    cd $SPIKE
    mkdir -p build; cd build
    ../configure --prefix=$TOP/tools
    make
    make install
```

------------------------------------------------------------------------
# Build Whisper

You must deactivate the conda environment before compiling Spike. Once
to exit the sparta env, once again to exit the base conda environment. Your
prompt should not show (base) or (sparta) when you have successfully
deactivated the environments.

```
  conda deactivate     # sparta
  conda deactivate     # base
  cd <workspace>/condor
  source how-to/env/setuprc.sh
```

Proceed with the build.

```
    cd $TOP
    git clone https://github.com/chipsalliance/VeeR-ISS.git whisper
    cd $WHISPER
    make
    cp build-Linux/whisper $TOOLS/bin
```

------------------------------------------------------------------------
# Build the benchmark suite

The Condor benchmark repo uses a mix of submodules and copies of external
repos. The copies contain source modified from the original repo to enable
STF generation.

## Cloning the benchmark repo

```
cd $TOP
git clone git@github.com:Condor-Performance-Modeling/benchmarks.git
cd benchmarks
git submodule update --init --recursive
```

## Building coremark

You must set the RISCV environment macro to the location of your
RISCV tool chain.

```
  cd $BENCHMARKS
  export RISCV=$RV_BAREMETAL_TOOLS
	make coremark
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

### Adding the instrumented exe to the linux image and running Dromajo

This assumes you have previously built the benchmark suite. 

The commands below copy the target exe to the buildroot file system, 
compiles the file system and copies the resulting rootfs.cpio to 
Dromajo's run directory. Finally executing on Dromajo

```
  cd $TOP
  sudo cp $BENCHMARKS/bin/coremark.riscv $BUILDROOT/output/target/sbin
  sudo make -C $BUILDROOT
  cp $BUILDROOT/output/images/rootfs.cpio $DROMAJO/run
  cd $DROMAJO/run
  ../build/dromajo --stf_trace my_trace.zstf boot.cfg
```

<!-- some versions require --ctrlc, some do not accept it        -->
<!-- ../build/dromajo --ctrlc --stf_trace my_trace.zstf boot.cfg -->

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
    - $> ./run.coremark-pro.sh nnet     (needs restart alt.4 file name already ...nnet)
    - <move stf file>
    - $> ./run.coremark-pro.sh parser   (done) 
    - <move stf file>
    - $> ./run.coremark-pro.sh radix2   (done) 
    - <move stf file>
    - $> ./run.coremark-pro.sh sha      (done)
    - <move stf file>
    - $> ./run.coremark-pro.sh zip      (done)
    - <move stf file>
