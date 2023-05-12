cmake_minimum_required(VERSION 3.15)

project(lib_image_loader VERSION 0.0.1)


# ./scripts/run ./scripts/docker-run.bash ./scripts/run ./scripts/build.bash

# Targets:
#  1. CPP target: image_loader_cpu
#  2. Eiegn target !


# Build types:
#   "Debug"
#   "Release"
#   "RelWithDebInfo"

enable_testing()

# Default values:
option(BUILD_TESTING "Build library tests" ON)
option(BUILD_EXAMPLE "Build example library usage test" OFF)
option(ENABLE_PROFILING "Enable the tool profiler" OFF)

list(INSERT CMAKE_MODULE_PATH 0 "${PROJECT_SOURCE_DIR}/CMake")

# Used in `cmake` step rather than `make` step. The standard expected "build type" set in cmake CLI. Also see CPackConfig.cmake
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
  "Debug"
  "Release"
  "RelWithDebInfo"
)

message(STATUS "LOG: BUILD TYPE: ${CMAKE_BUILD_TYPE}")
# message(STATUS "DEBUG: CONFIG TYPES: ${CMAKE_CONFIGURATION_TYPES}")

if(NOT DEFINED CMAKE_BUILD_TYPE)
    message(FATAL_ERROR "CMAKE_BUILD_TYPE is not set. Use: `cmake ... -DCMAKE_BUILD_TYPE=...`")
endif()
if(NOT DEFINED BUILD_TESTING)
    message(FATAL_ERROR "BUILD_TESTING is not set. Use: `cmake ... -DBUILD_TESTING=0 ...`")
endif()



find_package(Eigen3 REQUIRED)


#################################################################
# Compiler options and flags
#################################################################

# will change
#if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
#endif()

# todo: Modern practice: Use set_target_properties() instead. Don't change directly: CMAKE_CSS_FLAGS and done change CMAKE_CXX_FLAGS
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20 -Wall -fPIC")
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -fPIC")

# "old-school" way
#set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g ")
#set(CMAKE_C_FLAGS_DEBUG "-O0 -g ")

#set(CMAKE_CXX_FLAGS_RELEASE "-Ofast -funroll-loops -fvariable-expansion-in-unroller -faggressive-loop-optimizations -fvect-cost-model=dynamic -ftree-vectorizer-verbose=4") # vect flags dont seem to work?
#set(CMAKE_C_FLAGS_RELEASE   "-Ofast -funroll-loops -fvariable-expansion-in-unroller -faggressive-loop-optimizations -fvect-cost-model=dynamic -ftree-vectorizer-verbose=4")

# Targets:

#################################################################
# Target: CPU target, static
add_library(image_loader_cpu STATIC
    src/raster_image_loader.cpp
)

#[==[
target_include_directories(image_loader_cpu
  PUBLIC
    $<BUILD_INTERFACE:${lib_image_loader_BINARY_DIR}/include>
    $<BUILD_INTERFACE:${lib_image_loader_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
#]==]

set_target_properties(image_loader_cpu
  PROPERTIES
    CXX_STANDARD 20
    C_STANDARD 99
    CXX_STANDARD_REQUIRED ON
)

target_compile_features(image_loader_cpu
  PRIVATE
    cxx_std_20
)

# target_compile_features() or target_compile_options()

target_compile_options(image_loader_cpu
    PRIVATE
      -Wall
      # -fPIC
      # -O0
      # -g

      $<$<CONFIG:Debug>:
          # -DDEBUG_FLAG
          -g
      >
      $<$<CONFIG:Release>:
          -O2
          # instead of setting CMAKE_CXX_FLAGS_RELEASE
          -Ofast
          -funroll-loops
          -fvariable-expansion-in-unroller
          -faggressive-loop-optimizations
          -fvect-cost-model=dynamic
          -ftree-vectorizer-verbose=4
      >
      #  vect flags dont seem to work

      $<$<CONFIG:RelWithDebInfo>:
        # same
      >

)

target_compile_definitions(image_loader_cpu
  PRIVATE
    MYDEF=1
)


target_link_libraries(image_loader_cpu
  PRIVATE
    # Eigen3::Eigen
)


# Export also a namespaced alias
add_library(
  LibImageLoader::image_loader_cpu
  ALIAS
     image_loader_cpu
)

# cmake time, not make time
if(ENABLE_PROFILING)
  target_compile_definitions(image_loader_cpu
    PRIVATE
        PROFILE # as a `#define`
  )
endif()

#[==[
target_include_directories(image_loader_cpu

  # import
  PRIVATE
      # stb
      src/stb
      # If you only want the include directories to be used by targets that link to my_target, but not my_target itself, you can use the INTERFACE keyword.
      # used for compiling self

  # export
  #INTERFACE
  #    include
  #    # used for compiling others
  # In modern CMake, it is recommended to use build directory for all generated files and artifacts. That's why having an absolute path inside your source directory in your build specification is not recommended and CMake warns about it.
)
#]==]

message(STATUS "Current source directory: ${CMAKE_CURRENT_SOURCE_DIR}")
# Current source directory: /Users/sohail/opteran/work/image_loader

#[==[
target_include_directories(image_loader_cpu
  # export
  INTERFACE
      include
      #${CMAKE_CURRENT_SOURCE_DIR}/include
      # Error: cannot be a path that is located in the source directory.

      # error: is prefixed in the source directory
      # I see. I am exporting something inside the source (not built) ones
)
#]==]

target_include_directories(image_loader_cpu
  PRIVATE
      include
)

message(STATUS ${CMAKE_SOURCE_DIR})

#################################################################
# Installer
#################################################################

# The `cmake --install` command after the build step
set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR}/install)

message(STATUS "Export your library interface: for user's find_package()")

# rename target image_loader_cpu -> image_loader_lib
#  use a lib (somewhere), and remove cpu

install(
  TARGETS
    image_loader_cpu

  EXPORT
    CpuTargetSet

  ARCHIVE DESTINATION lib  # static libraries
  LIBRARY DESTINATION lib  # (shared) library (LIBRARY) for this target: shared libraries (also known as dynamic libraries), not static libraries.
  # RUNTIME DESTINATION bin  # No executable (RUNTIME) for this target
  INCLUDES DESTINATION include
  # FRAMEWORK

  # The destination paths are relative to the install prefix, which is typically set by the -DCMAKE_INSTALL_PREFIX option when running CMake.
)
# install prefix is determined by user's query and always varies (is the main thing that needs to be changed)

install(
  EXPORT
    CpuTargetSet

  # The name of the generated import file.
  # the generated lib-image-loader-config.cmake
  #   will contain commands to import the targets from my_export_set
  # another project can find_package(my_target)
  #
  # Defines an Export set: Generates a cmake file used by other packages that find_package() this, that is, a Package Configuration File: 
  # serves as a Package Configuration File:
  # FILE lib_image_loaderConfig2.cmake
  # FILE image_loader_hls-config.cmake
  # FILE lib-image-loader-importer.cmake
  # FILE lib-image-loader-config.cmake
  FILE lib_image_loader-config.cmake
  # FILE LibImageLoaderConfig.cmake
  # Findzulbia.cmake or zulbiaConfig.cmake
  # Findlibimageloader.cmake or libimageloaderConfig.cmake


  NAMESPACE LibImageLoader::
  DESTINATION lib/cmake/LibImageLoaderD # target name?
  #

  # only for
  CONFIGURATIONS
    Debug
    Release
    RelWithDebInfo
)
# usage will be:
#  find_package(image_loader_cpu)

# When you run the "install target" (i.e., when you run make install or ninja install).
# install itself is a target?
install(
  DIRECTORY
    include
    # by default, it doesn't include the top-level directory itself
    # If you want to include my_directory itself in the install directory, you can add a / at the end of the directory name
  DESTINATION
    include
)

######################################



set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
message(STATUS "${CPACK_PACKAGE_VERSION}")
set(CPACK_INSTALL_SCRIPT ${CMAKE_SOURCE_DIR}/CPackConfig.cmake)
if(NOT DEFINED CPACK_OUTPUT_FILE_PREFIX)
  set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/packages")
endif()


#################################################################
# Tests

if (BUILD_TESTING)
  # Enable test folder: Run its CMake
  message(STATUS "Building tests is enabled.")

  add_subdirectory(test)   # a sub-CMake

  message(STATUS "Building tests done.")
endif()

#if (BUILD_EXAMPLE)
#  message(STATUS "Building an example package that does find_package() on lib_image_loader's CMake file")
#  add_subdirectory(test/package_usage_example)   # a sub-CMake
#  message(STATUS "Building of the example for package usage done.")
#endif()


# using target_compile_features() instead:
#if(NOT DEFINED CMAKE_CXX_STANDARD)
#  message(FATAL_ERROR "error: CMAKE_CXX_STANDARD")
#endif()
#if(NOT DEFINED CMAKE_C_STANDARD)
#  message(FATAL_ERROR "error: CMAKE_C_STANDARD")
#endif()

# [1] based on https://github.com/Opteran/lib_spatial_comparison/blob/2f53fabd92314d5ae0ccef3c95523d8e4557320d/CMakeLists.txt

