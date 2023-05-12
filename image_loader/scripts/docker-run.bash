#!/bin/bash

set -exu

# How is $@ correct?!
# ./scripts/docker-run.bash aaa b
echo "CMD>>$@"
echo "CMD>>$0"  # temp name
echo "CMD>>$ORIGINAL_SCRIPT_NAME"

# workspace
export WS=$(realpath $REPO_ROOT/../..)
test -d $WS/src >/dev/null # verify

# cd $WS
echo "Workspace: $WS"

export ROS_DISTRO="${ROS_DISTRO:-humble}"

#export ROS_DISTRO=foxy
#export ROS_DISTRO=galactic
#export ROS_DISTRO=foxy

export os_ver="ubuntu-22.04"

# image:
#   "ghcr.io/opteran/ros_containers:$ROS_DISTRO-$osver-desktop-latest"
#   "osrf/ros:$ROS_DISTRO-desktop"
export DOCKER_IMAGE="ghcr.io/opteran/ros_containers:$ROS_DISTRO-$os_ver-desktop-latest"

echo dollar1 l= $1

command1=$1
# shift # or "${@:2}"
# "$@"

#     -u $(id -u):$(id -g) \

shift
# echo in docker:   $command1 "${@:2}"
echo in docker:   $command1 $@

#     -w "$WS/src/ros2_spatial_comparison" \
#  todo: go to -w or MY_PWD=$(pwd) relative to $WS
#     -w "$REPO_ROOT"  \
docker run \
    --rm  -it \
    -v "$WS":"$WS"  \
    -w "$(pwd)"  \
    -e "TERM=xterm-256color" \
    -e LOCAL_ON_DOCKER=1 \
    -e ROS_DISTRO="$ROS_DISTRO" \
    "$DOCKER_IMAGE"  \
    $command1 $@
    # "$WS/src/ros2_spatial_comparison/scripts/build-and-test.bash"  "${@:2}"


# wow:
# ./scripts/run ./scripts/docker-run.bash ./scripts/run ./scripts/build.bash
