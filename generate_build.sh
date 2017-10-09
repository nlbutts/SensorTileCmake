#!/bin/bash
# This script generates and builds everything for the sensortile build
# If you want the script to build the projects, pass in "make" as a commandline option
#
# Examples:
# 1) generates build code using cmake: ./generate_build
# 2) generates and makes projects:     ./generate_build make

main()
{
    # Get the directory that this script lives in
    THIS_SCRIPT_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

    # Set the build output path
    if [ -z "${BUILD_ROOT_PATH}" ]; then
        BUILD_ROOT_PATH=${THIS_SCRIPT_PATH}/build
    fi

    # Remove all previous builds
    mkdir -p ${BUILD_ROOT_PATH}
    rm -rf ${BUILD_ROOT_PATH}/*

    # Create builds
    create_build    arm         .           "${THIS_SCRIPT_PATH}/toolchain/arm_embedded_toolchain.txt" || exit 1
    #create_build    x86         .                                                           || exit 1

    # Build created projects, if option is set
    if [ "$1" == "make" ]; then
        make_all_builds
    fi

}

# $1 File to get the absolute path of
function realpath()
{
    echo $(cd $(dirname $1); pwd)/$(basename $1);
}

# Function - Creates the Cmake files for the build and makes
# $1 - Build platform name
# $2 - Optional toolchain file
function create_build()
{
    build_path="${BUILD_ROOT_PATH}/$1"
    cmake_args=""

    if [ -z "$1" ]; then
        printf "\n[ERROR - ${LINENO}] Bad arguments\n"
        #exit 1
    fi

    if [ -z "$2" ]; then
        printf "\n[ERROR - ${LINENO}] Bad arguments\n"
        #exit 1
    fi

    if [ ! -z "$4" ]; then
        cmake_args=${4}
    fi

    # Clear and create the build path
    printf "Clearing ${build_path}\n"
    mkdir -p ${build_path}
    rm -rf ${build_path}/*

    # Optionally select the toolchain file
    if [ ! -z "${3}" ]; then
        toolchain_file=$( realpath "${3}" )
        cmake_args="-DCMAKE_TOOLCHAIN_FILE:PATH=${toolchain_file}"
    fi

    # Call CMake to generate the build
    (
        set -x
        cd ${build_path} && cmake ${cmake_args} ${THIS_SCRIPT_PATH}/${2}
    )

    # Make sure cmake ran without issue
    if ! [ "$?" = "0" ]; then
        printf "\n[ERROR - ${LINENO}] Build step failed\n"
        exit 1
    fi
}

#Builds all directories in "BUILD_ROOT_PATH" when called.
function make_all_builds()
{
    for dir in ${BUILD_ROOT_PATH}/*
    {
        echo "---------- Building in: ${dir} ----------"
        (
        set -x
        cd "${dir}" && make -j4 install VERBOSE=1 || exit 1
        )
    }
}

# calls main function - basically, just keeps the main up top for readability.
main "$@"
