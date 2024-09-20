#!/bin/bash
#
# Determines if the given container is in the local repo.
# If not then it checks login state with the remote
# repo and prompts for login if necessary.
#
# Will need to be embellised with credential retrieval 
# needed for automated CI/CD runs. Have to avoid manual
# credential entry.
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_IMAGE=$2
CNTR_VER=$3
CNTR_REPO=$4
CNTR_PATH=$5
CNTR_NAME=$6

# Where to find script the lib.
# Will be co-located with script.
tmp1=${0%/}         # grab directoy path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-sgn-repo.bash

if ! sgnRepoHaveLocalImage ${CNTR_TECH} ${CNTR_PATH}; then
    if ! sgnRepoIsLoggedIn ${CNTR_TECH} ${CNTR_REPO}; then
        echo "(${CNTR_TECH}) Logging in to ${CNTR_REPO}"
        sgnRepoLoginRepo ${CNTR_TECH} ${CNTR_REPO}
    fi
fi
