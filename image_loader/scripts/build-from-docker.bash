#!/bin/bash

set -exu
# Can run from anywhere:
#SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
#REPO_ROOT=$(git rev-parse --show-toplevel)
#cd $REPO_ROOT

echo $REPO_ROOT
echo $ORIGINAL_SCRIPT_DIR
echo $ORIGINAL_SCRIPT_NAME


# workspace
export WS=$(realpath $REPO_ROOT/../..)
ls ./src >/dev/null # verify

cd $WS

echo "Workspace: $WS"


export ROS_DISTRO="${1:-humble}"

#export ROS_DISTRO="${1:-foxy}"
#export ROS_DISTRO=galactic
#export ROS_DISTRO=foxy

export os_ver="ubuntu-22.04"

# image:
#   "ghcr.io/opteran/ros_containers:$ROS_DISTRO-$osver-desktop-latest"
#   "osrf/ros:$ROS_DISTRO-desktop"

docker run \
    --rm  -it \
    -v "$WS":"$WS"   -w "$WS/src/ros2_spatial_comparison" \
    -e "TERM=xterm-256color" \
    -e LOCAL_ON_DOCKER=1 \
    -e ROS_DISTRO="$ROS_DISTRO" \
    "ghcr.io/opteran/ros_containers:$ROS_DISTRO-$os_ver-desktop-latest"  \
    "$WS/src/ros2_spatial_comparison/scripts/build-and-test.bash"  "${@:2}"

exit

    bash -c '
    adduser --disabled-password --gecos "User"     rosman ;
    su - rosman bash << EOF
    echo "hiii"
    "$WS/src/ros2_spatial_comparison/scripts/build-and-test.bash"  "${@:2}"
    EOF
    echo 'quit'
    whoami
    '

#     -u $(id -u):$(id -g) \
