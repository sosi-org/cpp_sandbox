#!/bin/bash

# set up ros context
# use with `source`

_flags_state=$-
#set -ex
set -eu  # immediately exit on error

# Can run from anywhere:
# this .source
SCRIPT_DIR0=$(cd -- "$(dirname -- $(realpath -s "${BASH_SOURCE[0]}" ) )" &>/dev/null && pwd)
# caller's .bash file (assume that itself is not "source"ed )
SCRIPT_DIR=$(cd -- "$(dirname -- $(realpath -s "${BASH_SOURCE[-1]}" ) )" &>/dev/null && pwd)
git config --global --add safe.directory /home/sohail/colcon_ws_lib_spatial_comparison/src/ros2_spatial_comparison
REPO_ROOT=$(git rev-parse --show-toplevel)
cd $REPO_ROOT

export WS=$(realpath -s $REPO_ROOT/../..)
ls ./src >/dev/null # verify

#prevent errors
#AMENT_TRACE_SETUP_FILES=${AMENT_TRACE_SETUP_FILES:-}
#AMENT_PYTHON_EXECUTABLE=${AMENT_PYTHON_EXECUTABLE:-}
#AMENT_PREFIX_PATH=${AMENT_PREFIX_PATH:-}
#PYTHONPATH=${PYTHONPATH:-}
#LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}

# BASH_SOURCE
#adduser --disabled-password --gecos "User"     rosman
#su - rosman
#whoami
#echo "REPO_ROOT=$REPO_ROOT"
#exit

#cd $REPO_ROOT
#sudo rm -rf build install log
#cd $WS
#sudo rm -rf build install log

export ROS_DISTRO="${ROS_DISTRO:-humble}"

set +u
# see [1]
source /opt/ros/$ROS_DISTRO/setup.bash

#cd $REPO_ROOT/../ros2_spatial_msgs
#rosdep install -i --from-path src --rosdistro "$ROS_DISTRO"

# cd $REPO_ROOT
cd $WS
# In WS, before building
rosdep install -i --from-path src --rosdistro "$ROS_DISTRO"

set -u
