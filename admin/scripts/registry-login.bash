#!/bin/bash
#
# ---------------------------------------------------------------------

# Where to find lib-container-registry script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-container-registry.bash

# ---------------------------------------------------------------------

getValueFromFile()
{
    if [ -f $1 ]; then
        cat $1
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------

getEnvVarName()
{
    local name=${CNTR_REGISTRY/"."/"_"}  # docker.io --> docker_io
    name=${name^^}                        # convert to uppercase
    name=${name}$1                        # add suffix
    # ex: given "docker.io" then tokenEnvVar equals "DOCKER_IO_PAT"
    echo ${name}
}

# ---------------------------------------------------------------------

getEnvVarValue()
{
    # Get and return value of environment variable.
    # Will be emtpy if it doesn't exist.
    echo $(eval echo \$${1})
}

# ---------------------------------------------------------------------

promptForRegistryToken()
{
    echo "needPrompt"
}

# ---------------------------------------------------------------------

promptForUsernameToken()
{
    echo "TODO: Prompt for username token"
    # Use LOGNAME if user enters empty
}

# ---------------------------------------------------------------------

getRegistryToken()
{
    tokenFileName="${HOME}/.ssh/${CNTR_REGISTRY}-token"
    tokenEnvVarName=$(getEnvVarName "_PAT")

    REGISTRY_TOKEN=$(getEnvVarValue ${tokenEnvVarName})
    if [ -z "${REGISTRY_TOKEN}" ]; then
        echo "(api-key) Checking env var \"${tokenEnvVarName}\", not found"
        REGISTRY_TOKEN=$(getValueFromFile ${tokenFileName})
        if [ -z "${REGISTRY_TOKEN}" ]; then
            echo "(api-key) Checking file \"${tokenFileName}\", not found"
            REGISTRY_TOKEN=""
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
    usernameFileName="${HOME}/.ssh/${CNTR_REGISTRY}-username"
    usernameEnvVarName=$(getEnvVarName "_USERNAME")

    USERNAME_TOKEN=$(getEnvVarValue ${usernameEnvVarName})
    if [ -z "${USERNAME_TOKEN}" ]; then
        echo "(username) Checking env var \"${usernameEnvVarName}\", not found"
        USERNAME_TOKEN=$(getValueFromFile ${usernameFileName})
        if [ -z "${USERNAME_TOKEN}" ]; then
            echo "(username) Checking file \"${usernameFileName}\", not found"
            USERNAME_TOKEN=""
        else
            echo "(username) Checking file \"${usernameFileName}\", found"
        fi
    else
        echo "(username) Checking env var \"${usernameEnvVarName}\", found"
    fi
    
}

# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_REGISTRY=$2

if [ -z ${CNTR_REGISTRY} ]; then
    echo "Missing argument 2, CNTR_REGISTRY must be supplied"
    return 1   # return false
fi

if crIsLoggedIn ${CNTR_TECH} ${CNTR_REGISTRY}; then
    echo "(${CNTR_TECH}) Already logged in to ${CNTR_REGISTRY}"
    return 0   # return true, already logged in
fi

# check for env variable <REGISTRY>_PAT      ("." turned into underscore)
# check for env variable <REGISTRY>_USERNAME
# check for access token in file in ~/.ssh <REGISTRY>-token
# check for username file in ~/.ssh <REGISTRY>-username
# if no token, prompt for token
# if no username, prompt for token

echo "(${CNTR_TECH}) Logging in to ${CNTR_REGISTRY}"
echo "(${CNTR_REGISTRY}) gathering credentials for Auto-Login"

getRegistryToken
getUsernameToken

if [ -n "${REGISTRY_TOKEN}" -a -n "${USERNAME_TOKEN}" ]; then
    echo "(${CNTR_REGISTRY}) Auto-login"
else
    echo "(${CNTR_REGISTRY}) Manually logging in"
fi

if [ -n "${REGISTRY_TOKEN}" ]; then
    PASSWORD_ARGS="--password ${REGISTRY_TOKEN}"
else
    # Leave PASSWORD_ARGS undefined
    :
fi

if [ -z "${USERNAME_TOKEN}" ]; then
    promptForUsernameToken
fi

# echo "HOWIE registry token = ${REGISTRY_TOKEN}"
# echo "HOWIE username token = ${USERNAME_TOKEN}"


# If PASSWORD_ARGS is empty then docker/podman will prompt
# for password from command line.
echo ${CNTR_TECH} login --username ${USERNAME_TOKEN} ${PASSWORD_ARGS}
















# ---------------------------------------------------------------------
# ---------------------------------------------------------------------

getRegistryTokenFromFile()
{
    tokenFile=${HOME}/.ssh/${CNTR_REGISTRY}-token

    if [ -f ${tokenFile} ]; then
        cat ${tokenFile}
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------

getUsernameTokenFromFile()
{
    usernameFile=${HOME}/.ssh/${CNTR_REGISTRY}-username

    if [ -f ${usernameFile} ]; then
        cat ${usernameFile}
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------

getRegistryTokenFromEnv()
{
    # Form environment variable name
    declare -g tokenEnvVar
    tokenEnvVar=${CNTR_REGISTRY/"."/"_"}  # docker.io --> docker_io
    tokenEnvVar=${tokenEnvVar^^}          # convert to uppercase
    tokenEnvVar=${tokenEnvVar}_PAT        # add suffix
    # ex: given "docker.io" then tokenEnvVar equals "DOCKER_IO_PAT"

    # Get and return value of environment variable.
    # Will be emtpy if it doesn't exist.
    # local t=$(eval echo \$${tokenEnvVar})
    echo $(eval echo \$${tokenEnvVar})
}

# ---------------------------------------------------------------------

getUsernameTokenFromEnv()
{
    # Form environment variable name
    declare -g usernameEnvVar
    usernameEnvVar=${CNTR_REGISTRY/"."/"_"}   # docker.io --> docker_io
    usernameEnvVar=${usernameEnvVar^^}        # convert to uppercase
    usernameEnvVar=${usernameEnvVar}_USERNAME # add suffix
    # ex: given "docker.io" then tokenEnvVar equals "DOCKER_IO_USERNAME"

    # Get and return value of environment variable.
    # Will be emtpy if it doesn't exist.
    # local u=$(eval echo \$${usernameEnvVar})
    echo $(eval echo \$${usernameEnvVar})
}

