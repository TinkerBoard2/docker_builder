FROM ubuntu:16.04

ARG DEBIAN_FRONTEND=noninteractive
ARG userid
ARG groupid
ARG username

# Install required packages for building Tinker Edge R Debian
# kmod: depmod is required by "make modules_install"
RUN apt-get update && \
    apt-get install -y make gcc bc python libssl-dev liblz4-tool sudo time \
    qemu-user-static g++ patch wget cpio unzip rsync bzip2 perl gcc-multilib \
    git kmod

RUN groupadd -g $groupid $username && \
    useradd -m -u $userid -g $groupid $username && \
    echo "$username ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    echo $username >/root/username

ENV HOME=/home/$username
ENV USER=$username
WORKDIR /source

ENTRYPOINT chroot --skip-chdir --userspec=$(cat /root/username):$(cat /root/username) / /bin/bash -i
