FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG userid
ARG groupid
ARG username

# Install required packages for building Tinker Edge R Debian
# kmod: depmod is required by "make modules_install"
COPY packages /packages

# Install required packages for building Debian
RUN apt-get update && \
    apt-get install -y repo git-core gitk git-gui gcc-arm-linux-gnueabihf \
    u-boot-tools device-tree-compiler gcc-aarch64-linux-gnu mtools parted \
    libudev-dev libusb-1.0-0-dev python-linaro-image-tools linaro-image-tools \
    gcc-4.8-multilib-arm-linux-gnueabihf gcc-arm-linux-gnueabihf libssl-dev \
    gcc-aarch64-linux-gnu g+conf autotools-dev libsigsegv2 m4 intltool \
    libdrm-dev curl sed make binutils build-essential gcc g++ bash patch gzip \
    bzip2 perl tar cpio python unzip rsync file bc wget libncurses5 libqt4-dev \
    libglib2.0-dev libgtk2.0-dev libglade2-dev cvs git mercurial rsync \
    openssh-client subversion asciidoc w3m dblatex graphviz python-matplotlib \
    libssl-dev texinfo liblz4-tool genext2fs

# Install additional packages
RUN apt-get install -y time gcc-multilib

# kmod: depmod is required by "make modules_install"
RUN apt-get update && apt-get install -y kmod expect patchelf

# Install additional packages for building base debian system by ubuntu-build-service from linaro
RUN apt-get install -y binfmt-support qemu-user-static live-build
RUN dpkg -i /packages/* || apt-get install -f -y

RUN groupadd -g $groupid $username && \
    useradd -m -u $userid -g $groupid $username && \
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo $username >/root/username

ENV HOME=/home/$username
ENV USER=$username
WORKDIR /source

ENTRYPOINT chroot --skip-chdir --userspec=$(cat /root/username):$(cat /root/username) / /bin/bash -i
