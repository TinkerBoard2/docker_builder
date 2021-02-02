FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive
ARG userid
ARG groupid
ARG username

# Install required packages for building Tinker Board 2 Debian
# kmod: depmod is required by "make modules_install"
COPY packages /packages

# Install required packages for building Debian
RUN apt-get update
RUN apt-get install -y repo git ssh make gcc libssl-dev liblz4-tool expect g++ patchelf chrpath gawk texinfo chrpath diffstat binfmt-support qemu-user-static live-build bison flex fakeroot cmake gcc-multilib g++-multilib unzip device-tree-compiler python-pip ncurses-dev python-pyelftools

# kmod: depmod is required by "make modules_install"
RUN apt-get update && apt-get install -y kmod expect patchelf

RUN apt-get update && apt-get install -y zip

# Install additional packages for building base debian system by ubuntu-build-service from linaro
RUN apt-get install -y binfmt-support qemu-user-static live-build
RUN apt-get install -y bc time rsync
RUN wget http://launchpadlibrarian.net/343927385/device-tree-compiler_1.4.5-3_amd64.deb
RUN dpkg -i device-tree-compiler_1.4.5-3_amd64.deb
RUN dpkg -i /packages/* || apt-get install -f -y
RUN rm device-tree-compiler_1.4.5-3_amd64.deb

RUN groupadd -g $groupid $username && \
    useradd -m -u $userid -g $groupid $username && \
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo $username >/root/username

ENV HOME=/home/$username
ENV USER=$username
WORKDIR /source

ENTRYPOINT chroot --skip-chdir --userspec=$(cat /root/username):$(cat /root/username) / /bin/bash -i
