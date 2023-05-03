# how-to
documentation and tips for using the condor performance modeling flow

# Condor-Performance-Modeling

Condor-Performance-Modeling (CPM) is a github organization. This organization 
contains multiple repos. This is the documentation repo, 
Condor-Performance-Modeling/how-to.

The steps that follow document building the Condor perf modeling environment 
and provide instructions on how to use it.

--------------------------------------
# ToC

1. [Boot strapping the environment](#boot-strapping-the-environment)

1. [Set local environment variables](#set-local-environment-variables)

1. [Install the Ubuntu collateral](#install-the-ubuntu-collateral)

1. [Install riscv gnu tool chain](#install-riscv-gnu-tool-chain)
    
1. [Install MAP](#install-map)

    1. [Install Miniconda](#install-miniconda)
    1. [Install Conda components](#install-conda-components)
    1. [Build and install Sparta](#build-and-install-sparta)
    1. [Build and install Helios/Argos](#build-and-install-helios-argos)

1. [Build STF Lib](#build-stf-lib)

1. [Install Olympia](#install-olympia)

1. [Using pipeline data views](#using-pipeline-data-views)

1. [Build Dromajo](#build-dromajo)

1. [Build the Linux Kernel](#build-the-linux-kernel)

1. [Build the Linux file system](#build-the-linux-file-system)

1. [Boot linux on Dromajo](#boot-linux-on-dromajo)

--------------------------------------
# Boot strapping the environment

Presumably you are reading this how-to from the web or a local copy. This
section boot straps the how-to environment.

- Change directory to the place you want to install condor tools 
  and environment.
- Make a directory called condor
- cd to condor
- clone this condor performance modeling how-to repo

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
mkdir Downloads
source how-to/env/setupenv.sh
```


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
# Install RISCV GNU Tool Chain

Some estimates say ~7GB of space is needed.

There are pre-built versions of the bare metal and linux tools. See
Jeff to get the link. These versions can save hours of compile time.

For the DIY-ers see this page: [LINK](./CROSS_TOOL_CHAIN.md)

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

<i> Make sure you move the added .bashrc lines to a private rc file if you are in a managed environment.

<i>open new terminal or reload your environment</i>

----------------------------------------------------------
## Clone map and it's components

```
    cd $TOP
    git clone https://github.com/sparcians/map.git
    cd map
    git checkout 277037f3cc2594df0ba04e3ad92d41d95e9ea3f9
    cd $MAP/sparta
```

## Patch the source files (for Olympia)

<b>FIXME: Create actual patch files, for now copy the pre-edited files</b>

If you are building Olympia (riscv-perf-model) you copy over two files.

```
    cp $PATCHES/TreeNodeExtensions.cpp $MAP/sparta/src/TreeNodeExtensions.cpp
    cp $PATCHES/TreeNodeExtensions.hpp $MAP/sparta/sparta/simulation/TreeNodeExtensions.hpp
```

## Build sparta

See the apt install for the Ubuntu support packages above in "Install the 
Ubuntu collateral".

You should active the sparta/conda environment, see above.

```
    cd $MAP/sparta
    mkdir release; cd release
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j8
```

## Install Conda components

- Start a terminal with miniconda activated. See above.
    - The prompt will look like (base):
```
   (base) jeff@reynaldo:~/Development:
```

- Install the conda packages, activate the sparta conda environment

```
    cd $MAP
    conda install -c conda-forge jq 
    conda install -c conda-forge yq
    ./scripts/create_conda_env.sh sparta dev
    conda activate sparta
    cd $(git rev-parse --show-toplevel);
    mkdir -p release; cd release
    mkdir helios

    
```

A successfully activated sparta/conda environment will change your prompt to (sparta):

```
(sparta) jeff@reynaldo:~/Development/condor/map$
```

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
    cd $MAP/release/helios
    cp -r ../../helios/release/pipeViewer .
```

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

---------

</i>
# Install Olympia

riscv-perf-model aka Olympia. Olympia is a trace driven OOO performance model.

The model is intended as a template, e.g. there is an advisory that renaming 
has not been implemented.

It does have some interesting capabilities in terms of trace input formats in [STF](https://github.com/sparcians/stf_spec) and [JSON](https://github.com/riscv-software-src/riscv-perf-model/tree/master/traces#json-inputs).

## Clone the repo

There are errors in map/Sparta source files when compiling for Olympia.  Make the source file changes described above (TreeNodeExtensions.hpp/cpp).

There is also an error in Dispatch.hpp, see below.

```
    cd $TOP
    git clone --recursive https://@github.com/riscv-software-src/riscv-perf-model.git
```

## Build the Olympia performance model.

```
    cd $OLYMPIA
    mkdir -p release; cd release
    cmake .. -DCMAKE_BUILD_TYPE=Release -DSPARTA_BASE=$MAP/sparta
    # Select the build level
    make -j8           # build everything
    #make -j8 olympia  # build the simulator only
    #make -j8 regress  # as it says
```

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
    python3 ${MAP}/helios/pipeViewer/pipe_view/argos.py --database pipeout_ --layout-file cpu_layout.alf
```
----------------------------------
</i>

# Build Dromajo

The original README for adding tracing to dromajo is in the olympia traces readme.
$OLYMPIA/traces/README.md

## Clone and patch dromajo

FIXME: I need to re-create the patch, there was a fix for console io performance in dromajo, so the checksum below is no longer used, and I need to verify that the patch still works

A patch is supplied to modify Dromajo to generate STF traces. These steps clone the repo, checkout the known compatible commit and patch the source.

```
;#    cd $TOP
;#    Experimental - skip these for now
;#    git clone git@github.com:Condor-Performance-Modeling/condor.dromajo.git
;#    ln -s condor.dromajo dromajo


    cd $TOP
    git clone https://github.com/chipsalliance/dromajo
    cd dromajo
    git checkout 86125b31
    git apply $PATCHES/dromajo_stf_lib.patch
    ln -s ../stf_lib
```

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

## Compile dromajo

```
    cd $DROMAJO
    mkdir -p build; cd build
    # FIXME: this is an uglier than normal hack
    cp $OLYMPIA/traces/stf_trace_gen/trace_macros.h $TOP
    cmake ..
    make -j8
```

## Verify patch

Check if patch worked, dromajo should have the --stf_trace option

```
    cd $DROMAJO/build
    ./dromajo | grep stf_trace
    console:
        --stf_trace <filename>  Dump an STF trace
```

------------------------------------------------------------------------
# Build the Linux kernel
## Check path to the linux gnu tool chain

Check that riscv64-unknown-linux-gnu-gcc is in your path.

```
which riscv64-unknown-linux-gnu-gcc
```

If not export to your PATH variable as shown.

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
    cd ..
```

------------------------------------------------------------------------
# Boot Linux on Dromajo

You must have previously installed the riscv gnu tool chain.
See [Install riscv gnu tool chain](#install-riscv-gnu-tool-chain)

This assumes you have built the pre-reqs, opensbi, linux kernel and linux 
file system. See instructions above.


## Copy collateral and boot linux

```
    cd $DROMAJO
    cp $BUILDROOT/output/images/rootfs.cpio ./run
    cp $KERNEL/arch/riscv/boot/Image ./run
    cp $OPENSBI/build/platform/generic/firmware/fw_jump.bin ./run
    cd run
    ../build/dromajo --ctrlc boot.cfg

```
login is root, password is root

Use Control-C or 'kill <pid>' to exit dromajo.

------------------------------------------------------------------------

# Running programs on dromajo

For now I'm referencing external docs for running dromajo.

[Running baremetal and linux based apps on dromajo](https://github.com/chipsalliance/dromajo/blob/master/doc/setup.md)

[Running instrumented apps on dromajo to generate STF traces](https://github.com/riscv-software-src/riscv-perf-model/tree/master/traces)


------------------------------------------------------------------------
# Instrumenting a linux based application

cd $DROMAJO/run

Edit program to contain START_TRACE; and STOP_TRACE;

vi dhrystone/dhry_1.c

...
START_TRACE;
for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
...
} /* loop "for Run_Index" */
STOP_TRACE;
...

make

riscv64-unknown-elf-gcc -c -O3 -DTIME -I./dhrystone -I../../riscv-perf-model/traces/stf_trace_gen dhrystone/dhry_1.c -o obj/dhry_1.o

riscv64-unknown-elf-gcc -c -O3 -DTIME -I./dhrystone -I../../riscv-perf-model/traces/stf_trace_gen dhrystone/dhry_2.c -o obj/dhry_2.o

riscv64-unknown-elf-gcc  obj/dhry_1.o obj/dhry_2.o -o bin/dhry.riscv.elf

cd $DROMAJO
sudo cp run/bin/dhry.riscv.elf ./buildroot-2020.05.1/output/target/sbin/

sudo make -C buildroot-2020.05.1
cd run

cp ../buildroot-2020.05.1/output/images/rootfs.cpio .
../build/dromajo --ctrlc --stf_trace my_trace.zstf boot.cfg

login: root
password: root

dhry.riscv.elf

