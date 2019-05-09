#!/bin/bash

set -e

if [ -x "$(command -v docker)" ]; then
    echo "Docker is installed and the execute permission is granted."
    if getent group docker | grep &>/dev/null "\b$(id -un)\b"; then
	echo "User $(id -un) is in the group docker."
    else
        echo "Docker is not managed as a non-root user."
	echo "Please refer to the following URL to manage Docker as a non-root user."
        echo "https://docs.docker.com/install/linux/linux-postinstall/"
	exit
    fi
else
    echo "Docker is not installed or the execute permission is not granted."
    echo "Please refer to the following URL to install Docker."
    echo "http://redmine.corpnet.asus/projects/configuration-management-service/wiki/Docker"
    exit
fi

if dpkg-query -s qemu-user-static 1>/dev/null 2>&1; then
    echo "The package qemu-user-static is installed."
else
    echo "The package qemu-user-static is not installed yet and it will be installed now."
    sudo apt-get install -y qemu-user-static
fi

if dpkg-query -s binfmt-support 1>/dev/null 2>&1; then
    echo "The package binfmt-support is installed."
else
    echo "The package binfmt-support is not installed yet and it will be installed now."
    sudo apt-get install -y binfmt-support
fi

DIRECTORY_PATH_TO_SOURCE="$(dirname $(dirname $(readlink -f $0)))"

if [ $# -eq 0 ]; then
    echo "There is no directory path to the source provided."
    echo "Use the default directory path to the source [$DIRECTORY_PATH_TO_SOURCE]."
else
    DIRECTORY_PATH_TO_SOURCE=$1
    if [ ! -d $DIRECTORY_PATH_TO_SOURCE ]; then
        echo "The source directory [$DIRECTORY_PATH_TO_SOURCE] is not found."
        exit
    fi
fi

DOCKER_IMAGE="asus/tinker_edge_r-linux-builder:latest"
#cp ~/.gitconfig gitconfig
cp -r $DIRECTORY_PATH_TO_SOURCE/debian/ubuntu-build-service/packages $DIRECTORY_PATH_TO_SOURCE/docker_builder/.
docker build --build-arg userid=$(id -u) --build-arg groupid=$(id -g) --build-arg username=$(id -un) -t $DOCKER_IMAGE \
    --file $DIRECTORY_PATH_TO_SOURCE/docker_builder/Dockerfile $DIRECTORY_PATH_TO_SOURCE/docker_builder
rm -rf $DIRECTORY_PATH_TO_SOURCE/docker_builder/packages

OPTIONS="--privileged --rm -it"
OPTIONS+=" --volume $DIRECTORY_PATH_TO_SOURCE:/source"
echo "Options to run docker: $OPTIONS"

docker run $OPTIONS $DOCKER_IMAGE
