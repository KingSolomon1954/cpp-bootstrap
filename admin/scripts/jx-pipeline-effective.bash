#!/bin/bash
#
# ---------------------------------------------------------------------
set -e

CNTR_TECH=$1
CNTR_USER=$2
CNTR_JX_PIPELINE_PATH=$3
PIPELINE_DIR=$4
BLD_PIPELINE=$5
GIT_SERVER=$6
GIT_USERNAME=
GIT_TOKEN=

runPipelineEffective()
{
    # $1 File path
    FILENAME=${1##*/}
    if [[ ${FILENAME} == "triggers.yaml" ]]; then
        return
    fi

    local CNTR_USER_FLAGS=
    if [[ ! -z ${CNTR_USER} && ${CNTR_USER} != root ]]; then
        CNTR_USER_FLAGS="--user=${CNTR_USER} --env HOME=/root"
    fi

    ${CNTR_TECH} run --rm \
        ${CNTR_USER_FLAGS} \
        --volume=${PWD}:/work \
        --workdir=/work \
        ${CNTR_JX_PIPELINE_PATH} \
        effective -f $1 -o ${BLD_PIPELINE}/$FILENAME --git-server ${GIT_SERVER} --git-username ${GIT_USERNAME} --git-token ${GIT_TOKEN}

    echo "Effective pipeline for $1 at ${BLD_PIPELINE}/$FILENAME"
}


getGitCredentials()
{
    echo "Git credentials"
    read -p "Username: " GIT_USERNAME
    read -s -p "Personal Access Token: " GIT_TOKEN
}

getGitCredentials

for f in ${PIPELINE_DIR}/*.yaml; do
    runPipelineEffective $f
done
