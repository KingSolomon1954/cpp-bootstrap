#!/usr/bin/env bash
#
# Starts the given image as the build container.
#
# The build container is launched in detached mode with specific
# well-known mount points "/work" one folder above repositories.
#
#   Example:
#       elvis/proj/          <-- container mount point, mounted as "/work"
#               cpp-bootstrap
#               project1
#               RedFlame
#
# Invocation looks something like this:
#
#   docker run --volume="$HOME/proj/:/work" --workdir=/work \
#              --detach -it --name docker.io/kingsolomon/gcc14-tools \
#              gcc14-tools
#
# Using this mount strategy, you can use the same already
# running build container to build in different repos.
#
# To more easily work with this mount strategy,
# developers should define aliases similar to the following:
#
#   alias bt='docker exec -w /work/$(basename $(pwd))              gcc14-tools'
#   alias bd='docker exec -w /work/$(basename $(pwd))/_build/debug gcc14-tools'
#   alias bp='docker exec -w /work/$(basename $(pwd))/_build/prod  gcc14-tools'
#
# ---------------------------------------------------------------------

# The container technology, which refers to podman or docker
CNTR_TECH=$1

# The username or UID and optionally the groupname or GID for
# the specified command. e.g., "1000:1000", "root", etc. If this
# value is empty, the user will be root.
# NOTE: When passing a variable into the script for this argument, 
#       wrap the variable in quotes since this is a positional argument 
#       and can be empty. e.g.,
#       start-bld-container.bash $(CNTR_TECH) "$(CNTR_USER)" ...
CNTR_USER=$2

# The URL of the container registry hosting the image, e.g., docker.io
# If needed, the script will login to the registry before pulling the
# image.
CNTR_REGISTRY=$3

# The full URL of the container image (including the image tag)
# e.g., docker.io/KingSolomon/cpp-bootstrap/gcc14-tools:14.2.0
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
#       network namespace with the host machine. The "cluster-mgmt-tools"
#       container typically remains running and using the "--net=host" flag
#       alleviates tying up ports that can collide with other containers
#       e.g., "Pytest Runner Container"; mainly when using the "-p"
#       parameter that claims the ports even though they may not be used.
DBG_PORT=$6

# Where to find the lib-container-registry script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-container-registry.bash

# ---------------------------------------------------------------------

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
        #
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

    echo "Starting ${CNTR_NAME}"

    # Start the container
    ${CNTR_TECH} run \
        ${CNTR_USER_FLAGS} \
        ${KUBE_CONFIG_MOUNT} \
        --volume=${PROJ_HOME}:/work \
        --volume=/sys/fs/cgroup:/sys/fs/cgroup:ro \
        --workdir=/work --detach -it \
        --cap-add=SYS_PTRACE \
        --no-healthcheck \
        ${CNTR_PORT_FLAGS} \
        ${CNTR_ARGS} \
        --name ${CNTR_NAME} ${CNTR_PATH}

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

# ---------------------------------------------------------------------

if cntrIsContainerRunning ${CNTR_TECH} ${CNTR_NAME}; then
    exit 0
fi

if cntrIsContainerExited ${CNTR_TECH} ${CNTR_NAME}; then
    echo "Starting exited bld-container: ${CNTR_NAME}"
    cntrStartExitedContainer ${CNTR_TECH} ${CNTR_NAME}
    exit 0
fi

if ! cntrHaveLocalImage ${CNTR_TECH} ${CNTR_PATH}; then
    if ! cntrIsLoggedIn ${CNTR_TECH} ${CNTR_REGISTRY}; then
        ${dirName}/registry-login.bash ${CNTR_TECH} ${CNTR_REGISTRY}
    fi
fi

startFreshBuildContainer

# ---------------------------------------------------------------------
