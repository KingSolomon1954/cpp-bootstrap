#!/bin/bash
#
# ---------------------------------------------------------------------
#
# Manages login to the given Conan registry.
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
# For example, if container registry is `conan.io` then looks 
# for these environment variables:
#
#   CONAN_IO_PAT         # personal access token / password
#   CONAN_IO_USERNAME    # login user name for this registry
#
# Reads credentials (personal access token(PAT) or password and 
# user name) from files if found:
#
# checks for access token in file in `~/.ssh/<REGISTRY>-token`
# checks for username file in `~/.ssh/<REGISTRY>-username`
#
# For example, if container registry is `conan.io` then looks 
# for these files:
#
#   $HOME/.ssh/conan.io-token     # personal access token / password
#   $HOME/.ssh/conan.io-username  # login user name for this registry
#
# These files have just a single line each. For example:
#
# > cat $HOME/.ssh/conan.io-token
# ccenter_675b9Jam99721
# > cat $HOME/.ssh/conan.io-username
# Elvis
#
# if no env var or file, then prompts for PAT/password
# if no env var or file, then prompts for username
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CONAN_REGISTRY=$2
BLD_CNTR_NAME=$3

# Where to find lib-conan-registry script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-conan-registry.bash

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
    # For example, if CONAN_REGISTRY = conan.io and $1 = "_PAT" 
    # then returns "CONAN_IO_PAT"
    
    local name=${CONAN_REGISTRY/"."/"_"}  # conan.io --> conan_io
    name=${name/"-"/"_"}                  # conan-io --> conan_io
    name=${name^^}                        # convert to uppercase
    name=${name}$1                        # add suffix
    echo ${name}
}

# ---------------------------------------------------------------------

promptForUsernameToken()
{
    # echo "Default = ${LOGNAME}"
    read -p "(${CONAN_REGISTRY}) Username: " USERNAME_TOKEN
    # Use LOGNAME if user enters empty
    # if [ -z "${USERNAME_TOKEN}" ]; then
    #     USERNAME_TOKEN=${LOGNAME}
    # fi
}

# ---------------------------------------------------------------------

promptForUrl()
{
    read -p "(${CONAN_REGISTRY}) URL: " REGISTRY_URL
}

# ---------------------------------------------------------------------

promptForToken()
{
    read -s -p "(${CONAN_REGISTRY}) Password: " REGISTRY_TOKEN
    echo ""
}

# ---------------------------------------------------------------------

getRegistryToken()
{
    tokenFileName="${HOME}/.ssh/${CONAN_REGISTRY}-token"
    tokenEnvVarName=$(makeEnvVarName "_PAT")
    declare -n tokenEnvVarValue=${tokenEnvVarName}

    REGISTRY_TOKEN=${tokenEnvVarValue}
    if [ -z "${REGISTRY_TOKEN}" ]; then
        echo "(api-key) Checking env var \"${tokenEnvVarName}\", not found"
        REGISTRY_TOKEN=$(getValueFromFile ${tokenFileName})
        if [ -z "${REGISTRY_TOKEN}" ]; then
            echo "(api-key) Checking file \"${tokenFileName}\", not found"
        else
            echo "(api-key) Checking file \"${tokenFileName}\", found"
        fi
    else
        echo "(api-key) Checking env var \"${tokenEnvVarName}\", found"
    fi
}

# ---------------------------------------------------------------------

getUsernameToken()
{
    usernameFileName="${HOME}/.ssh/${CONAN_REGISTRY}-username"
    usernameEnvVarName=$(makeEnvVarName "_USERNAME")
    declare -n usernameEnvVarValue=${usernameEnvVarName}
    
    USERNAME_TOKEN=${usernameEnvVarValue}
    if [ -z "${USERNAME_TOKEN}" ]; then
        echo "(username) Checking env var \"${usernameEnvVarName}\", not found"
        USERNAME_TOKEN=$(getValueFromFile ${usernameFileName})
        if [ -z "${USERNAME_TOKEN}" ]; then
            echo "(username) Checking file \"${usernameFileName}\", not found"
        else
            echo "(username) Checking file \"${usernameFileName}\", found"
        fi
    else
        echo "(username) Checking env var \"${usernameEnvVarName}\", found"
    fi
}

# ---------------------------------------------------------------------

getRegistryUrl()
{
    urlFileName="${HOME}/.ssh/${CONAN_REGISTRY}-url"
    urlEnvVarUrl=$(makeEnvVarName "_URL")
    declare -n urlEnvVarValue=${urlEnvVarUrl}

    REGISTRY_URL=${urlEnvVarValue}
    if [ -z "${REGISTRY_URL}" ]; then
        echo "(url) Checking env var \"${urlEnvVarUrl}\", not found"
        REGISTRY_URL=$(getValueFromFile ${urlFileName})
        if [ -z "${REGISTRY_URL}" ]; then
            echo "(url) Checking file \"${urlFileName}\", not found"
        else
            echo "(url) Checking file \"${urlFileName}\", found"
        fi
    else
        echo "(url) Checking env var \"${urlEnvVarUrl}\", found"
    fi
}

# ---------------------------------------------------------------------

if [ -z ${CONAN_REGISTRY} ]; then
    echo "Missing argument 2, CONAN_REGISTRY must be supplied"
    exit 1   # exit error
fi

if [ -z ${BLD_CNTR_NAME} ]; then
    echo "Missing argument 3, Name of build container must be supplied"
    exit 1   # exit error
fi

if ! conanHaveRegistry ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME}; then
    echo "(conan) Adding ${CONAN_REGISTRY} to Conan registry"
    getRegistryUrl
    if [ -z "${REGISTRY_URL}" ]; then
        promptForUrl
    fi
    echo "(${CONAN_REGISTRY}) Adding Conan registry ${CONAN_REGISTRY}"
    conanAddRegistry ${CNTR_TECH} ${CONAN_REGISTRY} \
                     ${BLD_CNTR_NAME} ${REGISTRY_URL}
fi

if conanIsLoggedIn ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME}; then
    echo "(${CONAN_REGISTRY}) Already logged in to ${CONAN_REGISTRY}"
    exit 0   # exit success, already logged in
fi

echo "(${CONAN_REGISTRY}) Logging into container registry: ${CONAN_REGISTRY}"
echo "(${CONAN_REGISTRY}) Gathering credentials for Auto-Login"

getRegistryToken
getUsernameToken

if [ -n "${REGISTRY_TOKEN}" -a -n "${USERNAME_TOKEN}" ]; then
    echo "(${CONAN_REGISTRY}) Auto-login"
else
    echo "(${CONAN_REGISTRY}) Manual-login"
fi

if [ -z "${USERNAME_TOKEN}" ]; then
    promptForUsernameToken
fi

if [ -z "${REGISTRY_TOKEN}" ]; then
    promptForToken
fi

# Change or set the username on the registry if different.
conanSetUsername ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME} ${USERNAME_TOKEN}

# Execute login.
conanLogin ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME} ${REGISTRY_TOKEN}

# ---------------------------------------------------------------------
