# ---------------------------------------------------------------------
#
# Library of bash functions to help with Conan registries.
#
# This file is sourced from several scripts.
#
# Functions prefixed with cr (conan registry)
#
# conanIsLoggedIn()
# conanLogoutRegistry()
# conanGetUsername()
# conanSetUsername()
# conanLogin()
# conanHaveRegistry()
# conanAddRegistry()
#
# ----------------------------------------------------------------------
#
# Helper function whether to invoke command in container.
# 
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
#
techCmd()
{
    if [ -z "${NO_BLD_CNTR}" ]; then
        echo -n "$1 exec $2"
    else
        echo -n ""
    fi
}

# ---------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
#
conanIsLoggedIn()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3

    local cmd=$(techCmd $1 $2)
    if ${cmd} conan remote list-users | \
        sed -n "/${regy}:/,+2p" | grep -i "true"; then \
        return 0    # return true, logged in
    fi
    return 1        # return false, not logged in
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
#
conanLogoutRegistry()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3

    local cmd=$(techCmd $1 $2)
    ${cmd} conan remote logout ${regy}
}

# ---------------------------------------------------------------------

promptForUsernameToken()
{
    read -p "(${CONAN_REGISTRY}) Username: " uname
    echo -n "${uname}"
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
    read -s -p "(${regy}) Password: " passwd
    echo -n "${passwd}"
}

# ---------------------------------------------------------------------

getValueFromFile()    # $1 is file name
{
    if [ -f $1 ]; then
        cat $1
    else
        echo -n
    fi
}

# ---------------------------------------------------------------------

makeEnvVarName()    # $1 is suffix
{
    # For example, if CONAN_REGISTRY = conan.io and $1 = "_PAT"
    # then returns "CONAN_IO_PAT"

    local name=${regy/"."/"_"}  # conan.io --> conan_io
    name=${name/"-"/"_"}        # conan-io --> conan_io
    name=${name^^}              # convert to uppercase
    name=${name}$1              # add suffix
    echo -n ${name}
}

# ---------------------------------------------------------------------

getUsernameToken()
{
    local usernameFileName="${HOME}/.ssh/${regy}-username"
    local usernameEnvVarName=$(makeEnvVarName "_USERNAME")
    declare -n usernameEnvVarValue=${usernameEnvVarName}

    local usernameToken=${usernameEnvVarValue}
    if [ -z "${usernameToken}" ]; then
        echo "(username) Checking env-var \"${usernameEnvVarName}\", not found"
        usernameToken=$(getValueFromFile ${usernameFileName})
        if [ -z "${usernameToken}" ]; then
            echo "(username) Checking file \"${usernameFileName}\", not found"
        else
            echo "(username) Checking file \"${usernameFileName}\", found"
        fi
    else
        echo "(username) Checking env-var \"${usernameEnvVarName}\", found"
    fi

    if [ -z "${usernameToken}" ]; then
        usernameToken=$(promptForUsernameToken)
    fi
    USERNAME_TOKEN=${usernameToken}
}

# ---------------------------------------------------------------------

getRegistryToken()
{
    local tokenFileName="${HOME}/.ssh/${regy}-token"
    local tokenEnvVarName=$(makeEnvVarName "_PAT")
    declare -n tokenEnvVarValue=${tokenEnvVarName}

    local registryToken=${tokenEnvVarValue}
    if [ -z "${registryToken}" ]; then
        echo "(api-key) Checking env-var \"${tokenEnvVarName}\", not found"
        registryToken=$(getValueFromFile ${tokenFileName})
        if [ -z "${REGISTRY_TOKEN}" ]; then
            echo "(api-key) Checking file \"${tokenFileName}\", not found"
        else
            echo "(api-key) Checking file \"${tokenFileName}\", found"
        fi
    else
        echo "(api-key) Checking env-var \"${tokenEnvVarName}\", found"
    fi

    if [ -z "${registryToken}" ]; then
        registryToken=$(promptForRegistryToken)
        echo
    fi
    REGISTRY_TOKEN=${registryToken}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
#
conanGetUsername()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3

    # Given that Conan returns somthing like this for list-users:
    #
    # conancenter:
    #   No user
    # aws-arty:
    #   Username: kingsolomon
    #   authenticated: False
    #
    # The following command line does the following:
    #
    #   * List the users, which gets all users for all registries
    #     (it's the only option)
    #   * Isolate to the registry of interest - 1st sed cmd
    #   * Grab the first line after the registry - the tail cmd
    #   * Strip out "  Username:" - 2nd sed cmd
    #
    # What's left is the actual username, so that gets echo'ed and
    # becomes the return value of this function.

    local cmd=$(techCmd $1 $2)
    ${cmd} conan remote list-users ${regy} | \
        sed -n "/${regy}:/,+1p" | tail -1 | \
        sed -e "s/  Username://" -e "s/ //g"
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
# USERNAME=$4
#
conanSetUsername()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3
    local uname=$4

    if [ -z ${uname} ]; then
        return 1  # return false, make no change
    fi
    # Change the username on the registry if different
    existingUsername=$(conanGetUsername ${tech} ${regy} ${bldCntrName})
    # Change usernames if they are different
    if [[ "${uname}" != "${existingUsername}" ]]; then
        local cmd=$(techCmd $1 $2)
        ${cmd} conan remote set-user ${regy} ${uname}
    fi
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
#
conanLogin()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3

    if conanIsLoggedIn ${tech} ${bldCntrName} ${regy}; then
        echo "(conan) Already logged in to Conan registry: ${regy}"
        return 0   # return success, already logged in
    fi
    echo "(${regy}) Gathering credentials for Auto-Login"
    getUsernameToken
    getRegistryToken
    # Change or set the username on the registry if different.
    conanSetUsername ${tech} ${bldCntrName} ${regy} ${USERNAME_TOKEN}

    local cmd=$(techCmd $1 $2)
    ${cmd} conan remote login -p ${REGISTRY_TOKEN} ${regy} ${USERNAME_TOKEN}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
#
conanHaveRegistry()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3

    local cmd=$(techCmd $1 $2)
    if ${cmd} conan remote list | grep -q ${regy}; then
        return 0   # return true, found it
    fi
    return 1       # return false, not found
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
# CONAN_REGISTRY_URL=$4
#
conanAddRegistry()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3
    local url=$4

    if [ -z ${url} ]; then
        echo "(conan) lib-conan-registry.bash: conanAddRegistry(): Must supply Conan Registry URL"
        return 1  # return false, make no change
    fi
    
    local cmd=$(techCmd $1 $2)
    ${cmd} conan remote add -f ${regy} ${url}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
#
conanEnableRegistry()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3

    local cmd=$(techCmd $1 $2)
    ${cmd} conan remote enable ${regy}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
#
conanDisableRegistry()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3

    local cmd=$(techCmd $1 $2)
    ${cmd} conan remote disable ${regy}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# BLD_CNTR_NAME=$2
# CONAN_REGISTRY=$3
#
conanIsRegistryEnabled()
{
    local tech=$1
    local bldCntrName=$2
    local regy=$3

    local cmd=$(techCmd $1 $2)
    ${cmd} conan remote list  | \
        grep ${regy} | grep -i "Enabled: True" > /dev/null
}

# ----------------------------------------------------------------------
