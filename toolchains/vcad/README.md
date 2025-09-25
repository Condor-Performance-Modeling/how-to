# Readme

## Summary

VCAD grid environment is a bit different from CAWS. It's based on RHEL8 system images and is lacking root privileges
for users making it a bit hard to build and install packages.

So building environment is based on Docker and RHEL8 UBI (universal base image). Prepared dockerfile used to build
image was used for GCC 15.1.0 and LLVM 21.1.0. Even for those versions some packages from RHEL8 UBI were outdated or
paywalled by Red Hat, that's why they are built from sources, during image creation. So it might happen that container
would require update in the future, to be able to provide newer toolchains builds.

## Steps
1. Prerequisites 
* Properly set up Condor CAWS environment (how-to)
* Docker installed (`sudo apt install -y docker.io`)
1. Build image
```shell
cd $TOP/how-to/toolchains/vcad
sudo DOCKER_BUILDKIT=1 docker build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) --build-arg USERNAME=$(whoami) -t rhel8-toolchain-build-image .
```
2. Build toolchain using image
```shell
sudo docker run -it --rm -u $(id -u):$(id -g) -v /caws/nfsvcad:/caws/nfsvcad -v $TOP:$TOP rhel8-toolchain-build-image bash $TOP/how-to/toolchains/gcc/build_gcc.sh
sudo docker run -it --rm -u $(id -u):$(id -g) -v /caws/nfsvcad:/caws/nfsvcad -v $TOP:$TOP rhel8-toolchain-build-image bash $TOP/how-to/toolchains/llvm/build_llvm.sh
```
`/caws/nfsvcad` path is mapped to the container, and it's suggested base path to install toolchain. Execute  scripts and
follow the steps they are requiring. Prepare yourself proper paths you want to have the toolchains installed to as they 
are likely not copyable (not tested thoroughly, but during brief verification after copy it was seen that some search 
paths are hardcoded into the toolchain's binaries/libraries).