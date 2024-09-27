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
# ---------------------------------------------------------------------
#
# CNTR_TECH=$1
# CONAN_REGISTRY=$2
# BLD_CNTR_NAME=$3
#
conanIsLoggedIn()
{
    local tech=$1
    local regy=$2
    local bldCntrName=$3

    if ${tech} exec ${bldCntrName} conan remote list-users | \
        sed -n "/${regy}:/,+2p" | grep -i "true"; then \
        return 0    # return true, logged in
    fi
    return 1        # return false, not logged in
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CONAN_REGISTRY=$2
# BLD_CNTR_NAME=$3
#
conanLogoutRegistry()
{
    local tech=$1
    local regy=$2
    local bldCntrName=$3

    ${tech} exec ${bldCntrName} conan remote logout ${regy}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CONAN_REGISTRY=$2
# BLD_CNTR_NAME=$3
#
conanGetUsername()
{
    local tech=$1
    local regy=$2
    local bldCntrName=$3

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
    
    ${tech} exec ${bldCntrName} conan remote list-users ${regy} | \
        sed -n "/${regy}:/,+1p" | tail -1 | sed -e "s/  Username://"
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CONAN_REGISTRY=$2
# BLD_CNTR_NAME=$3
# USERNAME=$4
#
conanSetUsername()
{
    local tech=$1
    local regy=$2
    local bldCntrName=$3
    local uname=$4

    if [ -z ${uname} ]; then
        return 1  # return false, make no change
    fi

    # Change the username on the registry if different
    existingUserame=$(conanGetUsername ${tech} ${regy} ${bldCntrName})
    # Change usernames if they are different
    if [ "${uname}" != "${existingUserame}" ]; then
        ${tech} exec ${bldCntrName} conan remote set-user ${regy} ${uname}
    fi
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CONAN_REGISTRY=$2
# BLD_CNTR_NAME=$3
# PASSWORD_TOKEN=$4
#
conanLogin()
{
    local tech=$1
    local regy=$2
    local bldCntrName=$3
    local passwd=$4

    # TODO: figure out how Auth works, because "conan remote auth"
    # command does not take an arg for password.
    
    ${tech} exec ${bldCntrName} conan remote auth ${regy}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CONAN_REGISTRY=$2
# BLD_CNTR_NAME=$3
#
conanHaveRegistry()
{
    local tech=$1
    local regy=$2
    local bldCntrName=$3

    if ${tech} exec ${bldCntrName} conan remote list | grep ${regy}; then
        return 0   # return true, found it
    fi
    return 1       # return false, not found
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CONAN_REGISTRY=$2
# BLD_CNTR_NAME=$3
# CONAN_REGISTRY_URL
#
conanAddRegistry()
{
    local tech=$1
    local regy=$2
    local bldCntrName=$3
    local url=$4

    if [ -z ${url} ]; then
        echo "(conan) lib-conan-registry.bash: conanAddRegistry(): Must supply Conan Registry URL"
        return 1  # return false, make no change
    fi
    
    ${tech} exec ${bldCntrName} conan remote add -f ${regy} ${url}
}

# ----------------------------------------------------------------------
