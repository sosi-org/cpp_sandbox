
pwd
echo "BUILD"

echo "REPO_ROOT=$REPO_ROOT"
echo "ORIGINAL_SCRIPT_DIR=$ORIGINAL_SCRIPT_DIR"
echo "ORIGINAL_SCRIPT_NAME=$ORIGINAL_SCRIPT_NAME"


# based on https://github.com/Opteran/lib_spatial_comparison/blob/2f53fabd92314d5ae0ccef3c95523d8e4557320d/scripts/build-and-test.bash


echo "Warning: This script is for documentation proposes. Don't run this script in production or CI pipelines."

set -exu

# Can run from anywhere:
# SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# REPO_ROOT=$(git rev-parse --show-toplevel)
cd $REPO_ROOT

#########################################################


export cmake_build_type=Debug
# export cmake_build_type=Release
# todo: should give error
# export cmake_build_type=Milease

########################### lint ########################
# todo: linting etc

# env CC=clang CXX=clazy cmake \
#    -DCMAKE_CXX_CLANG_TIDY:STRING='clang-tidy;-checks=-*,readability-*' \
#    -DCMAKE_CXX_INCLUDE_WHAT_YOU_USE:STRING='include-what-you-use;-Xiwyu;--mapping_file=/iwyu.imp' \
#    ..

# cmake --help

test -f  "$REPO_ROOT/src/raster_image_loader.cpp"


########################### build ########################
# clean up
rm -rf build

mkdir -p build

cd $REPO_ROOT/build
# CMAKE ✓   MAKE ✗
cmake ..  -DCMAKE_BUILD_TYPE=${cmake_build_type}  -DBUILD_TESTING=1 \
    --log-level=VERBOSE  --warn-uninitialized \
    # --graphviz=gvz.dot \
    # --trace-expand

              # sudo apt install xdot # for graphviz output

# or alternatively:
cd $REPO_ROOT
# CMAKE ✓   MAKE ✗
cmake -S . -B ./build


# The `make`` (the actual build) step:

# CMAKE ✗   MAKE ✓
cd build && \
make

# or alternatively:
cd $REPO_ROOT/build
# CMAKE ✗   MAKE ✓  (equivalent to `make``:)
cmake --build . --config ${cmake_build_type}




########################### install (optional) ########################

# Disabling cpack for now: (default `cpack` does not work?)
# cpack  --verbose  #--trace-expand  # Note: Looks for release/CPackConfig.cmake

# MAKE ONLY
rm -rf install && mkdir -p install && touch install/.gitkeep
# Warning: May install in Linux system directories.
# make install
# saves in ./install



########################### test ########################

export GTEST_PRINT_TIME=1
export GTEST_COLOR=1

# ctest  --show-only --rerun-failed --output-on-failure
ctest  --output-on-failure

# Alternatively, You can also run the tests manually: using the test executable directly, which provides more detailed test output:
if false; then
cd $REPO_ROOT/build
./test/spatial_comparison_cpu_eigen_tests --gtest_filter="*.*"
./test/spatial_comparison_cpu_tests --gtest_filter="*.*"
./test/spatial_comparison_vitis_compatible_tests --gtest_filter="*.*"
fi

# CI cmake commands:
#
#        ctest  --output-on-failure
#

