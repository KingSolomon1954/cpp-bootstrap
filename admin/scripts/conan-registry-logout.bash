#!/bin/bash
#
# File: conan-registry-logout.bash
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CONAN_REGISTRY=$2
BLD_CNTR_NAME=$3

if [ -z ${CONAN_REGISTRY} ]; then
    echo "Missing argument 2, CONAN_REGISTRY must be supplied"
    return 1   # return false
fi

if [ -z ${BLD_CNTR_NAME} ]; then
    echo "Missing argument 3, Name of build container must be supplied"
    return 1   # return false
fi

# Where to find lib-conan-registry script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-conan-registry.bash

podman exec ${BLD_CNTR_NAME} conan remote logout ${CONAN_REGISTRY}

if crIsLoggedIn ${CNTR_TECH} ${CONAN_REGISTRY}; then
    crLogoutRegistry ${CNTR_TECH} ${CONAN_REGISTRY}
else
    echo "(conan) Already logged out of ${CONAN_REGISTRY}"
fi
