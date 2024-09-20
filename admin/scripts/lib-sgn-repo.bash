# ---------------------------------------------------------------------
#
# Library of bash functions to help with container repositories.
#
# This file is sourced from several scripts.
#
# ---------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_PATH=$2
#
sgnRepoHaveLocalImage()
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
# CNTR_REPO=$2
#
sgnRepoIsLoggedIn()
{
    local tech=$1
    local repo=$2
    local dockerCfg=${HOME}/.docker/config.json

    if [ "${tech}" = "docker" ]; then
        if grep -i "${repo}" "${dockerCfg}" > /dev/null; then
            return 0  # return true, already logged in
        fi
        return 1      # return false, not logged in
    fi
    
    if [ "${tech}" = "podman" ]; then
        if ${tech} login --get-login ${repo} > /dev/null 2>&1; then
            return 0  # return true, already logged in
        fi
        return 1      # return false, not logged in
    fi
    echo "Bad CNTR_TECH arg in sgnRepoIsLoggedIn()"
    exit 1   # Fatal exit here.
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_REPO=$2
#
sgnRepoLoginRepo()
{
    local tech=$1
    local repo=$2
    echo "${tech} login -u ${LOGNAME} ${repo}"
    ${tech} login -u ${LOGNAME} ${repo}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_REPO=$2
#
sgnRepoLogoutRepo()
{
    local tech=$1
    local repo=$2
    echo "${tech} logout ${repo}"
    ${tech} logout ${repo}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_NAME=$2
#
sgnRepoStartExitedContainer()
{
    local tech=$1
    local name=$2
    echo "${tech} start ${name}"
    ${tech} start ${name}
}

# ----------------------------------------------------------------------
#
# CNTR_TECH=$1
# CNTR_NAME=$2
#
# Statuses (created, running, paused, exited)
#
sgnRepoIsContainerRunning()
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
sgnRepoIsContainerExited()
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
