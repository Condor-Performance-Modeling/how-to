# CPM Onboarding

A mix of instructions and links/pointers to other help.

Notes:
  - There are three domains
    - your Condor Computing laptop
    - Condor Computing's Cadence managed VCAD environment
    - Condor Computing's self managed AWS domain, aka C-AWS
  - As a result there are three separate ssh related steps and keys
    - your laptop setup for PUTTY access into AWS
    - your VCAD ssh setup for addition to your github account
    - your C-AWS ssh setup also for addition to your github account
  - There are three accounts
    - Condor Computing's Cadence managed VCAD environment
    - Condor Computing's self managed AWS domain, aka C-AWS
    - A github account that will be added to the Condor Perf. Modeling org.
  - Cadence will create your VCAD account
    - they will also send you instructions on how to access it
    - once this is done Jeff needs info from the VCAD account
  - You create your github account
  - Jeff will create your C-AWS account 

# Setup your VCAD account access

There are a number of pdf's that walk you through the process. They are
not the best but they are what we have from Cadence. Send questions to the 
slack #help channel or directly to Jeff

## Send your VCAD user info to Jeff

Once you can log in to VCAD issue the 'id' command and send Jeff the results. 
We use identical id info in Condor AWS.

> id
> uid=121790(jeffnye) gid=201(ccusers) groups=201(ccusers),5600(condorperf),7852(cuzco)
> whoami
> jeffnye

Send Jeff the output from id and whoami. 

## Create your .ssh key info in VCAD
cd
ssh-keygen
<passphrase>
<passphrase>

Instruction below will use the generated key, remember your passpharse.

# Github account

We keep shared files in a github repo under the Condor Performance Modeling
(CPM) organization.

You need a github account. Sign up if you do not otherwise have one. Send Jeff 
your github account name.

Once you have an account send me the account name.

Once I have your VCAD id info, VCAD user name and github account name I will

  - add you to the CPM github organization
  - create your AWS user account 
  - send you a note that this has been done 
      - this note will have a .pem file attachment

# Access Condor AWS 

Once Jeff receives your info Jeff will add you to the CPM github organization 
and create your C-AWS account.

Once this is complete Jeff will send you a note with an attached .pem file.

The .pem file is for putty access to C-AWS.

Once you have access follow the instructions from this [LINK](#https://github.com/Condor-Performance-Modeling/how-to/blob/main/AWS.md)

  - Configuring your credentials

