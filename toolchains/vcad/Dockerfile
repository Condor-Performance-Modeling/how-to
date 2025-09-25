# Use RHEL8 as the base image
FROM registry.access.redhat.com/ubi8/ubi

# Set working directory
ARG USER_ID
ARG GROUP_ID
ARG USERNAME

# Create user and group
RUN groupadd -g $GROUP_ID $USERNAME && \
    useradd -m -u $USER_ID -g $GROUP_ID $USERNAME

# Set home and working directory
ENV HOME=/home/$USERNAME
WORKDIR /home/$USERNAME

RUN yum install -y autoconf
RUN yum install -y automake
RUN yum install -y binutils
RUN yum install -y bzip2
RUN yum install -y cmake
RUN yum install -y ctags
RUN yum install -y curl
RUN yum install -y expect
RUN yum install -y file
RUN yum install -y gawk
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y gdb
RUN yum install -y git
RUN yum install -y glibc-devel
RUN yum install -y gmp-devel
RUN yum install -y libstdc++-static
RUN yum install -y libtool
RUN yum install -y m4
RUN yum install -y make
RUN yum install -y mpfr-devel
RUN yum install -y ncurses-devel
RUN yum install -y patch
RUN yum install -y perl
RUN yum install -y perl-Fedora-VSP
RUN yum install -y perl-generators
RUN yum install -y pkgconf
RUN yum install -y pkgconf-m4
RUN yum install -y pkgconf-pkg-config
RUN yum install -y python3.11
RUN yum install -y redhat-rpm-config
RUN yum install -y rpm-build
RUN yum install -y rpmlint
RUN yum install -y source-highlight
RUN yum install -y strace
RUN yum install -y tar
RUN yum install -y unzip
RUN yum install -y wget
RUN yum install -y which
RUN yum install -y xz
RUN yum install -y zlib-devel
RUN yum clean all

RUN wget https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.gz
RUN tar -xf texinfo-7.1.tar.gz
RUN cd texinfo-7.1/ && \
    rm -rf _build_rhel8 && \
    mkdir -p _build_rhel8 && cd _build_rhel8 && \
    ../configure --prefix=/usr && \
    make -j $(nproc) && make install
RUN rm -rf texinfo-7.1/

RUN wget https://github.com/westes/flex/files/981163/flex-2.6.4.tar.gz
RUN tar -xf flex-2.6.4.tar.gz
RUN cd flex-2.6.4/ && \
    rm -rf _build_rhel8 && \
    mkdir -p _build_rhel8 && cd _build_rhel8 && \
    ../configure --prefix=/usr && \
    make -j $(nproc) && make install
RUN rm -rf flex-2.6.4/

RUN wget https://ftp.man.poznan.pl/gnu/bison/bison-3.8.tar.xz
RUN tar -xf bison-3.8.tar.xz
RUN cd bison-3.8/ && \
    rm -rf _build_rhel8 && \
    mkdir -p _build_rhel8 && cd _build_rhel8 && \
    ../configure --prefix=/usr && \
    make -j $(nproc) && make install
RUN rm -rf bison-3.8

RUN wget https://github.com/libexpat/libexpat/archive/refs/tags/R_2_7_2.tar.gz
RUN tar -xf R_2_7_2.tar.gz
RUN cd libexpat-R_2_7_2/expat/ && \
    ./buildconf.sh && \
    ./configure --prefix=/usr/ && \
    make -j$(nproc) && make install
RUN rm -rf libexpat-R_2_7_2/

# Switch to the user
USER $USER_ID:$GROUP_ID
