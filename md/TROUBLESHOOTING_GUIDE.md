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

1. [Install Overview](#install-overview)

1. [Install Miniconda](#install-miniconda)

1. [CPM Environment Setup](#cpm-environment-setup)

1. [Boot Linux on CPM Dromajo](#boot-linux-on-cpm-dromajo)

1. [Build and Install the Golden Models](#build-and-install-the-golden-models)

1. [Boot Linux on Spike](#boot-linux-on-spike)

1. [Proceed to benchmarks](#proceed-to-benchmarks)

1. [Optional builds](#optional-builds)

    1. [Build and Install stf_tools](#build-and-install-stf_tools)

    1. [Patching SimPoint](#patching-simpoint)

1. [Updating compiler links](#updating-compiler-links)
   
----------------------------------------------------------

# Choosing a host
You should do most of your work on interactive1/2 or optionally compute1-7. 
You can directly log into compute1-7 but they are LSF machines so 
interactive1/2 are preferred.

When you first access C-AWS you will land you on gui1. Once on gui1 you 
should switch to one of the interactive or compute machines.

There are 3 gui machines, gui1-3. You can create a virtual desktop on any
of these 3 machines using the NoMachine launcher.

Typical commands:
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
git clone https://github.com/Condor-Performance-Modeling/how-to.git
source how-to/env/setuprc.sh
echo $TOP                         # this should not be empty
```
NOTE: If you are developing contents of the how-to repo it is easier to start with the ssh version of git clone
```
git clone git@github.com:Condor-Performance-Modeling/how-to.git
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
As of 12/2024 the sim farm includes
```
interactive1       Interactive jobs
compute1-7         LSF and general usage
gui1/gui2/gui3     Desktop servers only
utility1           Runs load watchers/VPN/etc, not for general use
```
The instructions for NoMachine will land you on gui1. You can create other sessions on gui1/2/3.  The guiN machines are intended to server desktops only.

Typical:
```
gui1> ssh interactive1
```

## Create a work area
Create a work area in C-AWS at /data/users/<login id>

interactive1> cd /data/users
interactive1> mkdir your_login_id
interactive1> cd your_login_id, etc etc.

/data is NFS mounted across all interactive and compute machines.

</details>

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
  <summary><b>Details: How to install miniconda</b></summary>

<br>
Execute the miniconda bash script

```
cd /data/users/$USER
bash /data/tools/env/Miniconda3-py312_24.7.1-0-Linux-x86_64.sh -p /data/users/$USER/miniconda3
```

Answer the license, location and init questions.

```
...snip...
Do you accept the license terms? [yes|no]
[no] >>> yes

Miniconda3 will now be installed into this location:
/data/users/<$USER>/miniconda3

  - Press ENTER to confirm the location
  - Press CTRL-C to abort the installation
  - Or specify a different location below

[/data/users/<$USER>/miniconda3] >>> <return>

Do you wish to update your shell profile to automatically initialize conda?
...snip...
by running conda init? [yes|no]
[no] >>> yes

```
<br>

The results of the above are:

- I am NOT using the default install location
- I am accepting the license
- I am allowing the installer to run conda init
- I am allowing the installer to modify my .bashrc

<!--
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
-->

<H2>Close this terminal and open a new terminal</H2>

Your prompt should start with <b>(base)</b>
</details>

</details> <!-- end of Linux, C-AWS and VCAD environments -->

----------------------------------------------------------

# CPM Environment Setup

The CPM Environment Setup is automated through scripts that:

- Verify the Base Miniconda Environment
- Setup the Sparta Conda environment
- Build Sparcians Components and Collateral Repos
- Build the CPM Golden Model

For a manual, step-by-step setup process, refer to the [CPM Environment Setup Step By Step](#cpm-environment-setup-step-by-step) section. This section provides links to the individual scripts and detailed instructions for manually setting up the environment.

## Verify the Base Miniconda Environment

Verify your conda environment is active. (base) should be in your prompt.

Issue these commands:

```bash
conda activate       
conda config --set report_errors false
cd /data/users/$USER/condor   # or your work area
source how-to/env/setuprc.sh
```

Make sure that your SSH key was added to the ssh-agent to clone repositories without interruptions. 

```bash
  eval `ssh-agent`
  ssh-add $HOME/.ssh/id_rsa
```

## Setup the Sparta Conda Environment 

Run script to set up Conda environment:

```bash
bash how-to/scripts/conda_env_setup.sh
conda activate sparta
```

## Build Sparcians Components and Collateral Repos
Your prompt should start with (sparta) after activation. Then run:

```bash
bash how-to/scripts/cpm_env_setup.sh
```

The cpm_env_setup.sh script completes the following stages:

1. Building Sparcians components
1. Building the Linux collateral
1. Building and Installing the CPM Repos

If there are no errors in this process skip to [Build the CPM Golden Model](#build-the-cpm-golden-model)

If there are errors the section below provides debug info.

### Troubleshooting

If the `cpm_env_setup.sh` setup script fails, it's designed to be re-run. It will pick up the process from the last completed stage. Alternatively, steps can be completed manually if needed (see the details section below).

<b>CPM Environment Setup Step By Step</b>

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
Building Map components step by step: [see script on GitHub](https://github.com/Condor-Performance-Modeling/how-to/blob/main/scripts/build_sparcians.sh)

</details>

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
Building the linux collateral step by step: [see script on GitHub](https://github.com/Condor-Performance-Modeling/how-to/blob/main/scripts/build_linux_collateral.sh)

</details>

<details>
  <summary>Details: Install the CPM Repos</summary>

# Install the CPM Repos

CPM -> Condor Performance Modeling

This install the CPM repos: benchmarks, CAM, tools, utils, cpm.riscv-perf-model, cpm.dromajo

```
cd $TOP
bash how-to/scripts/build_cpm_repos.sh

```
Installing the CPM repos step by step: [see script on GitHub](https://github.com/Condor-Performance-Modeling/how-to/blob/main/scripts/build_cpm_repos.sh)

</details>

----------------------------------------------------------

# Build the CPM Golden Model

A modified form of Spike (cpm.andes.riscv-isa-sim) is used to generate 
the traces used by CAM. The installation of this uses a manual step
to modify the PATH variable to add a bare metal cross compiler.

```
export PATH=$RV_ANDES_GNU_BAREMETAL_TOOLS/bin:$PATH
```

**NOTE**: This is an Andes supplied GNU toolchain that supports the Andes V5 performance extensions.

Next execute the build script.
```
cd $TOP
source how-to/env/setuprc.sh
bash how-to/scripts/build_cpm_andes_spike.sh
```

This clones, builds, and runs regression on the model. Any errors are reported to the console.


<!--
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
$TOOLS/bin/cpm_dromajo --ctrlc --stf_priv_modes USHM --stf_trace example.stf boot.cfg
```
Exit with Ctrl-C.

----------------------------------------------------------
# Build and Install the Golden Models and Associated Tools

## Exit Conda

<b>You must deactivate the conda environment before proceeding.</b>

Deactivate once to exit the sparta environment, once again to exit the base conda
environment.

Your prompt should not show (base) or (sparta) when you have
successfully deactivated the environments.

```
  conda deactivate     # leave sparta
  conda deactivate     # leave base
```

## Build CPM Spike

```
cd $TOP
bash how-to/scripts/build_cpm_spike.sh
```
  Build CPM Spike step by step: [see script on GitHub](https://github.com/Condor-Performance-Modeling/how-to/blob/main/scripts/build_cpm_spike.sh)



## Build the Associated Tools

```
cd $TOP
bash how-to/scripts/build_extra_tools.sh
```
Build the extra tools step by step: [see script on GitHub](https://github.com/Condor-Performance-Modeling/how-to/blob/main/scripts/build_extra_tools.sh)


----------------------------------------------------------

# Boot Linux on Spike

The above steps create the necessary collateral to boot linux on Spike.

The steps above create collateral files in $TOOLS/riscv-linux

<b>login is root, password is root</b> for both versions.

## Boot linux - SPIKE 
Copy the images/etc from previous steps to the Spike run directory.
```
cd $TOP
mkdir -p $SPIKE/run
cp $TOOLS/riscv-linux/* $SPIKE/run

cd $SPIKE/run
$TOOLS/bin/spike --kernel Image --initrd rootfs.cpio --bootargs "root=/dev/ram rw earlycon=sbi console=hvc0" fw_jump.elf 
```

Custom `isa` configuration for spike can be provided with the `--isa` switch.

This golden model doesn't exit on Ctrl-C. You must kill the PID to exit the simulation.

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

# Updating compiler links

The `update_compiler_links.sh` script is designed to set up symbolic links and update environment variables for RISC-V cross-compilation. It ensures that the paths to specific cross-compilers are correctly set, allowing easy switching between different RISC-V compiler versions or configurations. This script should be run **after the cross-compiler paths were updated in the `setuprc.sh` script located in `how-to/env/`**.

To use this script, navigate to your work area and run:
```bash
source how-to/env/setuprc.sh
bash how-to/scripts/update_compiler_links.sh
```
Updating compiler links step by step: [see script on GitHub](https://github.com/Condor-Performance-Modeling/how-to/blob/main/scripts/update_compiler_links.sh)
## What the script does
- Checks for Environment and Directory Requirements: Ensures that the `$TOP`, `$RISCV`, and `$RISCV_LINUX` are defined and exist.
- Sets up Symbolic Links: Links the `$TOP/riscv64-unknown-elf` and `$TOP/riscv64-unknown-linux-gnu` directories to the paths defined in `$RISCV` and `$RISCV_LINUX`, respectively. 

-->
