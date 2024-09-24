#!/bin/bash
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_REGISTRY=$2

if [ -z ${CNTR_REGISTRY} ]; then
    echo "Missing argument 2, CNTR_REGISTRY must be supplied"
    return 1   # return false
fi

# Where to find the lib-repo script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-container-registry.bash

if crIsLoggedIn ${CNTR_TECH} ${CNTR_REGISTRY}; then
    echo "(${CNTR_TECH}) Already logged in to ${CNTR_REGISTRY}"
    return 0   # return true, already logged in
fi

echo "(${CNTR_TECH}) Logging in to ${CNTR_REGISTRY}"

# check for access token in file in ~/.ssh <REGISTRY>-token
# check for username file in ~/.ssh <REGISTRY>-username
# check for env variable <REGISTRY>_PAT      ("." turned into underscore)
# check for env variable <REGISTRY>_USERNAME
# if no token, prompt for token
# if no username, use $LOGNAME

