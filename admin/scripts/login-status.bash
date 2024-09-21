#!/bin/bash
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_REPO=$2

if [ -z ${CNTR_REPO} ]; then
    CNTR_REPO=artifactory.apps.build.sgn.viasat.us
fi

# Where to find the lib-repo script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-repo.bash

if sgnRepoIsLoggedIn ${CNTR_TECH} ${CNTR_REPO}; then
    echo "(${CNTR_TECH}) Currently logged in to ${CNTR_REPO}"
else
    echo "(${CNTR_TECH}) Currently not logged in to ${CNTR_REPO}"
fi
