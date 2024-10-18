#!/usr/bin/env bash
#
# ---------------------------------------------------------------------
#
# Manages login to the given container registry.
#
# Supports automated and manual login.
#
# Credentials are read from these locations in this order:
#
#   1. environment variables
#   2. from files
#   3. otherwise command line prompt
#
# Reads credentials (personal access token(PAT) or password and 
# user name) from envionment variables if found:
#
# checks for env variable <REGISTRY>_PAT      ("." turned into underscore)
# checks for env variable <REGISTRY>_USERNAME
#
# For example, if container registry is `docker.io` then looks 
# for these environment variables:
#
#   DOCKER_IO_PAT         # personal access token / password
#   DOCKER_IO_USERNAME    # login user name for this registry
#
# Reads credentials (personal access token(PAT) or password and 
# user name) from files if found:
#
# checks for access token in file in `~/.ssh/<REGISTRY>-token`
# checks for username file in `~/.ssh/<REGISTRY>-username`
#
# For example, if container registry is `docker.io` then looks 
# for these files:
#
#   $HOME/.ssh/docker.io-token     # personal access token / password
#   $HOME/.ssh/docker.io-username  # login user name for this registry
#
# These files have just a single line each. For example:
#
# > cat $HOME/.ssh/docker.io-token
# dhub_675b9Jam99721
# > cat $HOME/.ssh/docker.io-username
# Elvis
#
# if no env var or file, then prompts for PAT/password
# if no env var or file, then prompts for username
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_REGISTRY=$2

# Where to find lib-container-registry script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-container-registry.bash

# ---------------------------------------------------------------------

checkArgs()
{
    if [ -z ${CNTR_REGISTRY} ]; then
        echo "${0}: Missing argument 2, CNTR_REGISTRY must be supplied"
        exit 1   # exit error
    fi
}

# ---------------------------------------------------------------------

getValueFromFile()    # $1 is file name
{
    if [ -f $1 ]; then
        cat $1
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------

makeEnvVarName()    # $1 is suffix
{
    # For example, if CNTR_REGISTRY = docker.io and $1 = "_PAT" 
    # then returns "DOCKER_IO_PAT"
    
    local name=${CNTR_REGISTRY/"."/"_"}  # docker.io --> docker_io
    name=${name^^}                       # convert to uppercase
    name=${name}$1                       # add suffix
    echo ${name}
}

# ---------------------------------------------------------------------

promptForUsernameToken()
{
    read -p "(${CNTR_REGISTRY}) Username: " uname
    echo "${uname}"
    # Maybe default to LOGNAME if user just presses enter
    # echo "Default = ${LOGNAME}"
    # Use LOGNAME if user enters empty
    # if [ -z "${uname}" ]; then
    #     uname=${LOGNAME}
    # fi
}

# ---------------------------------------------------------------------

promptForRegistryToken()
{
    read -s -p "(${CNTR_REGISTRY}) Password: " passwd
    echo "${passwd}"
}

# ---------------------------------------------------------------------

getRegistryToken()
{
    local tokenFileName="${HOME}/.ssh/${CNTR_REGISTRY}-token"
    local tokenEnvVarName=$(makeEnvVarName "_PAT")
    declare -n tokenEnvVarValue=${tokenEnvVarName}

    local registryToken=${tokenEnvVarValue}
    if [ -z "${registryToken}" ]; then
        echo "(api-key) Checking env var \"${tokenEnvVarName}\", not found"
        registryToken=$(getValueFromFile ${tokenFileName})
        if [ -z "${registryToken}" ]; then
            echo "(api-key) Checking file \"${tokenFileName}\", not found"
        else
            echo "(api-key) Checking file \"${tokenFileName}\", found"
        fi
    else
        echo "(api-key) Checking env var \"${tokenEnvVarName}\", found"
    fi
    if [ -z "${registryToken}" ]; then
        registryToken=$(promptForRegistryToken)
        echo
    fi
    REGISTRY_TOKEN=${registryToken}
}

# ---------------------------------------------------------------------

getUsernameToken()
{
    local usernameFileName="${HOME}/.ssh/${CNTR_REGISTRY}-username"
    local usernameEnvVarName=$(makeEnvVarName "_USERNAME")
    declare -n usernameEnvVarValue=${usernameEnvVarName}
    
    local usernameToken=${usernameEnvVarValue}
    if [ -z "${usernameToken}" ]; then
        echo "(username) Checking env var \"${usernameEnvVarName}\", not found"
        usernameToken=$(getValueFromFile ${usernameFileName})
        if [ -z "${usernameToken}" ]; then
            echo "(username) Checking file \"${usernameFileName}\", not found"
        else
            echo "(username) Checking file \"${usernameFileName}\", found"
        fi
    else
        echo "(username) Checking env var \"${usernameEnvVarName}\", found"
    fi
    if [ -z "${usernameToken}" ]; then
        usernameToken=$(promptForUsernameToken)
    fi
    USERNAME_TOKEN=${usernameToken}
}

# ---------------------------------------------------------------------

checkAlreadyLoggedIn()
{
    if cntrIsLoggedIn ${CNTR_TECH} ${CNTR_REGISTRY}; then
        echo "(${CNTR_TECH}) Already logged in to ${CNTR_REGISTRY}"
        exit 0   # exit success, already logged in
    fi
}

# ---------------------------------------------------------------------

doLogin()
{
    ${CNTR_TECH} login --username ${USERNAME_TOKEN} \
                       --password ${REGISTRY_TOKEN} ${CNTR_REGISTRY}
}

# ---------------------------------------------------------------------

echo "(${CNTR_TECH}) Logging into container registry: ${CNTR_REGISTRY}"
checkArgs
checkAlreadyLoggedIn            # Exits script if already logged in
echo "(${CNTR_REGISTRY}) Gathering credentials for Auto-Login"
getUsernameToken
getRegistryToken
doLogin

# ---------------------------------------------------------------------
