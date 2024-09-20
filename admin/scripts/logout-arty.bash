#!/bin/bash
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_REPO=$2

if [ -z ${CNTR_REPO} ]; then
    CNTR_REPO=artifactory.apps.build.sgn.viasat.us
fi

# Where to find script the lib.
# Will be co-located with script.
tmp1=${0%/}         # grab directoy path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-sgn-repo.bash

if sgnRepoIsLoggedIn ${CNTR_TECH} ${CNTR_REPO}; then
    sgnRepoLogoutRepo ${CNTR_TECH} ${CNTR_REPO}
else
    echo "(${CNTR_TECH}) Already logged out of ${CNTR_REPO}"
fi
