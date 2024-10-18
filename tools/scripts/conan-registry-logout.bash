#!/usr/bin/env bash
#
# File: conan-registry-logout.bash
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

# Unconditionally logout, no need to first check if already logged out.
conanLogoutRegistry ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME}

# if conanIsLoggedIn ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME}; then
#     conanLogoutRegistry ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME}
# else
#     echo "(conan) Already logged out of ${CONAN_REGISTRY}"
# fi
