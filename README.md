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

    1. [Verify the Base Miniconda Environment](#verify-the-base-miniconda-environment)

    1. [Setup the Sparta Conda Environment](#setup-the-sparta-conda-environment)

    1. [Build the CPM Components and Collateral](#build-the-cpm-components-and-collateral)

1. [Build the CPM Golden Model](#build-the-cpm-golden-model)

1. [Final Test](#final-test)

<!-- 1. [Other Guides](#other-guides) -->

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

----------------------------------------------------------
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

----------------------------------------------------------
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

<H2>Close this terminal and open a new terminal</H2>

Your prompt should start with <b>(base)</b>
</details>

</details> <!-- end of Linux, C-AWS and VCAD environments -->

----------------------------------------------------------
# CPM Environment Setup

The CPM Environment Setup is automated through scripts that:

- Verify the Base Miniconda Environment
- Setup the Sparta Conda environment
- Build the CPM Components and Collateral

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

The `conda_env_setup.sh` script has a built in fall-back method. If you see the
following the fall-back has been triggered.

```
::ERROR:: variant file <some message>
create_conda_env.sh failed, running fallback command 
```

If you see the following, the process was completed successfully. The error above was handled by the fall-back.
```
Setup process completed.                             
```

Now activate the sparta environment
```
conda activate sparta
```

## Build the CPM Components and Collateral
Your prompt should start with (sparta) after activation.

The `cpm_env_setup.sh` script completes the following stages:

1. Building Sparcians components
1. Building the Linux collateral (cross compiled)
1. Building and Installing the CPM Repos

Then run:

```bash
bash how-to/scripts/cpm_env_setup.sh
```

If there are no errors in this process skip to [Build the CPM Golden Model](#build-the-cpm-golden-model)

If there are errors see the [troubleshooting guide](https://github.com/Condor-Performance-Modeling/how-to/blob/main/md/TROUBLESHOOTING_GUIDE.md)

----------------------------------------------------------
# Build the CPM Golden Model

A modified form of Spike (cpm.andes.riscv-isa-sim) generates
the traces used by CAM. The installation of the model uses a manual step
to exit the conda environment.

The Andes GNU bare metal cross compiler is added to your path.

**NOTE**: This is an Andes supplied GNU toolchain that supports the Andes V5 performance extensions.

Exit conda using deactivate twice, once for (sparta), once to exit (base)
```
conda deactivate
conda deactivate
```

Next, execute the build script.
```
cd $TOP
source how-to/env/setuprc.sh
bash how-to/scripts/build_cpm_andes_spike.sh
```

This clones, builds, and runs a regression test on the model.
Any errors are reported to the console.

----------------------------------------------------------
# Final Test

This step is recommended. You can exercise the majority of the CPM 
environment from the benchmarks repo.

```
cd $TOP
source how-to/env/setuprc.sh
cd $BENCHMARKS
make
```

Once this completes there will be a PASS/FAIL indication in the console.

<!--

----------------------------------------------------------
# Other Guides

- Troubleshooting guide
- Booting Linux on Spike
- Booting the public fork of Spike
- Building other tools and utilities
- Patching SimPoint
- Updating compiler links

-->
