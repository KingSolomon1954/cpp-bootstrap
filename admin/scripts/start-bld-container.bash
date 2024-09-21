#!/bin/bash
#
# Starts the given build container in detached mode with
# specific well-known mount points.
#
# Container image xxx is running detached with root
# mount point /work one folder above repositories.
#
#   Example:
#       elvis/proj/sgn          <-- container mount point, mounted as "/work"
#               sgn-skeleton-cpp
#               sgn-skeleton-py
#               sgn-pktgen
#               sgn-api-async
#               bld-scripts
#
# Will look something like this:
#
#   docker run --volume="$HOME/proj/sgn:/work" --workdir=/work \
#              --detach -it --name sgn-python sgn-dev/sgn-python
#
# Using this mount strategy, you can use the same already
# running build container to build in many repos.
#
# This strategy is an optimization for a developers work
# flow on local computer. Developers would define
# aliases similar to the following:
#
#   alias sa='docker exec -w /work/$(basename $(pwd))        sgn-gcc10'
#   alias sb='docker exec -w /work/$(basename $(pwd))/_build sgn-gcc10'
#
# ---------------------------------------------------------------------

# The container technology, which refers to podman or docker
CNTR_TECH=$1

# The username or UID and optionally the groupname or GID for the specified command
# e.g., "1000:1000", "root", etc. If this value is empty, the user will be root.
# NOTE: When passing a variable into the script for this argument, wrap the
#       variable in quotes since this is a positional argument and can be empty.
#       e.g., start-bld-container.bash $(CNTR_TECH) "$(CNTR_USER)" ...
CNTR_USER=$2

# The URL of the repo hosting the image, e.g., artifactory.apps.build.sgn.viasat.us
# If needed, the script will login before pulling the image.
CNTR_REPO=$3

# The full URL of the container image (including the image tag)
# e.g., artifactory.apps.build.sgn.viasat.us/sgn-docker/sgn/bld/python39-tools:0.5.0-1-int
CNTR_PATH=$4

# The name to use when creating container. The script assumes the caller
# will track whether the container has already been created.
CNTR_NAME=$5

# A non-zero value indicates that the container should expose all of its
# ports to the host (e.g., --net=host option for Docker/Podman).
# The different non-zero values indicate further options:
#   1 - Expose all ports.
#   2 - Expose all ports. Use with OpenShift and port forwarding. The
#       ~/.kube directory will also be volume mounted into the container.
# The default is to not expose the container's ports to the host.
#
# NOTE: The parameter "--net=host" is also used to share the container's
#       network namespace with the host machine. The "sgn-cluster-mgmt-tools"
#       container typically remains running and using the "--net=host" flag
#       alleviates tying up ports that can collide with other containers
#       e.g., "Pytest Runner Container"; mainly when using the "-p"
#       parameter that claims the ports even though they may not be used.
DBG_PORT=$6

# Where to find the lib-repo script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-repo.bash

startFreshBuildContainer()
{
    # Set flags to run container as root / non-root user.
    local CNTR_USER_FLAGS=
    local CNTR_NEED_ROOT_DIR_PERMISSIONS=n
    # Apply the following flags for non-root users.
    if [[ ! -z ${CNTR_USER} && ${CNTR_USER} != root ]]; then
        CNTR_USER_FLAGS="--user=${CNTR_USER} --env HOME=/root"

        # Later in the script, take ownership of /root for non-root Docker
        # users. This flag is only applied when Docker is used, not Podman,
        # because the chown method does not work for Podman. Podman is
        # usually run as rootless with UID/GID mapping inside the container,
        # so that running "chown <host UID>" on a directory in the container
        # may unexpectedly change ownership of the file to a substitute
        # UID (e.g., 165536) rather than the actual host UID (e.g., 1000).
        if [[ ${CNTR_TECH} == docker ]]; then
            CNTR_NEED_ROOT_DIR_PERMISSIONS=y
        fi
    fi

    # Set flags to expose container ports to the host
    local CNTR_PORT_FLAGS=
    if [[ DBG_PORT == 1 || DBG_PORT == 2 ]]; then
        CNTR_PORT_FLAGS=--net=host
    fi

    # Set flags to volume mount the ~/.kube config directory
    local KUBE_CONFIG_MOUNT=
    if [[ DBG_PORT == 2 ]]; then
        KUBE_CONFIG_MOUNT=--volume=${HOME}/.kube/:/root/.kube
    fi

    # Set absolute path to the root of the project tree (i.e., one folder
    # above repositories) where the "/work" directory will be mounted.
    local PROJ_HOME=$(cd ..; echo $PWD)

    # Set Seccomp (Secure Computing Mode) profile options, which restrict
    # the system calls that can be made.
    # Darwin refers to macOS.
    if [ $(uname) = "Darwin" ]; then
        # Setting "unconfined" will disable the default Seccomp profile.
        local CNTR_ARGS="--security-opt=seccomp=unconfined"
    fi

    # Start the container
    ${CNTR_TECH} run \
        ${CNTR_USER_FLAGS} \
        ${KUBE_CONFIG_MOUNT} \
        --volume=${PROJ_HOME}:/work \
        --workdir=/work --detach -it \
        --cap-add=SYS_PTRACE \
        --no-healthcheck \
        ${CNTR_PORT_FLAGS} \
        -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
        ${CNTR_ARGS} \
        --name ${CNTR_NAME} ${CNTR_PATH}

    echo "Started ${CNTR_NAME}"

    # Since build containers tend to use the HOME directory for configs
    # when running build commands, also allow access to /root for the
    # non-root user. The /root directory is used instead the non-root
    # user's HOME since there are some pre-existing poetry configs in
    # /root/.config/pypoetry.
    if [[ ${CNTR_NEED_ROOT_DIR_PERMISSIONS} == y ]]; then
        ${CNTR_TECH} exec \
            --user=root \
            ${CNTR_NAME} \
            chown -R ${CNTR_USER} /root
        ${CNTR_TECH} exec \
            --user=root \
            ${CNTR_NAME} \
            chmod 750 /root
    fi
}

if sgnRepoIsContainerRunning ${CNTR_TECH} ${CNTR_NAME}; then
    exit 0
fi

if sgnRepoIsContainerExited ${CNTR_TECH} ${CNTR_NAME}; then
    echo "Starting exited bld-container: ${CNTR_NAME}"
    sgnRepoStartExitedContainer ${CNTR_TECH} ${CNTR_NAME}
    exit 0
fi

if ! sgnRepoHaveLocalImage ${CNTR_TECH} ${CNTR_PATH}; then
    if ! sgnRepoIsLoggedIn ${CNTR_TECH} ${CNTR_REPO}; then
        echo "(${CNTR_TECH}) Logging in to ${CNTR_REPO}"
        sgnRepoLoginRepo ${CNTR_TECH} ${CNTR_REPO}
    fi
fi

startFreshBuildContainer
