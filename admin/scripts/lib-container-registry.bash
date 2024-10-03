# ---------------------------------------------------------------------
#
# Library of bash functions to help with container registries.
#
# This file is sourced from several scripts.
#
# Functions prefixed with cr (container registry)
#
# cntrHaveLocalImage()
# cntrIsLoggedIn()
# cntrLogoutRegistry()
# cntrStartExitedContainer()
# cntrIsContainerRunning()
# cntrIsContainerExited()
#
# ---------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_PATH=$2
#
cntrHaveLocalImage()
{
    local tech=$1
    local path=$2
    local haveImage=$(${tech} images -q -f reference="${path}")
    if [ -z "${haveImage}" ]; then
        return 1  # return false, don't have it
    fi
    return 0      # return true, have it
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_REGISTRY=$2
#
cntrIsLoggedIn()
{
    local tech=$1
    local registry=$2
    local dockerCfg=${HOME}/.docker/config.json

    if [ "${tech}" = "docker" ]; then
        if grep -i "${registry}" "${dockerCfg}" > /dev/null; then
            return 0  # return true, already logged in
        fi
        return 1      # return false, not logged in
    fi
    
    if [ "${tech}" = "podman" ]; then
        if ${tech} login --get-login ${registry} > /dev/null 2>&1; then
            return 0  # return true, already logged in
        fi
        return 1      # return false, not logged in
    fi
    echo "Bad CNTR_TECH arg in cntrIsLoggedIn()"
    exit 1   # Fatal exit here.
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_REGISTRY=$2
#
cntrLogoutRegistry()
{
    local tech=$1
    local registry=$2
    # echo "${tech} logout ${registry}"
    ${tech} logout ${registry}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_NAME=$2
#
cntrStartExitedContainer()
{
    local tech=$1
    local name=$2
    # echo "${tech} start ${name}"
    ${tech} start ${name}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_NAME=$2
#
# Statuses (created, running, paused, exited)
#
cntrIsContainerRunning()
{
    local tech=$1
    local name=$2
    local cntrId=$(${tech} ps -q -f name=${name} -f status=running)
    if [ -z "${cntrId}" ]; then
        return 1  # return false, not running
    fi
    return 0      # return true, running
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_NAME=$2
#
# Statuses (created, running, paused, exited)
#
cntrIsContainerExited()
{
    local tech=$1
    local name=$2
    local cntrId=$(${tech} ps -a -q -f name=${name} -f status=exited -f status=created)
    if [ -z "${cntrId}" ]; then
        return 1  # return false, not exited
    fi
    return 0      # return true, exited
}

# ----------------------------------------------------------------------
