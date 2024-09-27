#!/bin/bash
#
# File: conan-registry-status.bash
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CONAN_REGISTRY=$2
BLD_CNTR_NAME=$3

if [ -z ${CONAN_REGISTRY} ]; then
    echo "Missing argument 2, CONAN_REGISTRY must be supplied"
    exit 1   # return error
fi

if [ -z ${BLD_CNTR_NAME} ]; then
    echo "Missing argument 3, Name of build container must be supplied"
    exit 1   # return error
fi

# Where to find lib-conan-registry script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-conan-registry.bash

if conanIsLoggedIn ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME}; then
    echo "(${CONAN_REGISTRY}) Already logged into ${CONAN_REGISTRY}"
else
    echo "(${CONAN_REGISTRY}) Not logged in to ${CONAN_REGISTRY}"
fi
