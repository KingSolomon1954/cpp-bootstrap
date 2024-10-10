# Set up handy development aliases and such

# The container technology (podman or docker)
if which podman 1>&2 > /dev/null; then
    CNTR_TECH=podman
elif which docker 1>&2 > /dev/null; then
    CNTR_TECH=docker
else
    echo "No podman or docker found"
    return 0
fi

_CPP_BOOTSTRAP_HOME=${HOME}/dev/proj/cpp-bootstrap

_GCC_IMG="ghcr.io/kingsolomon1954/lib/gcc14-tools"
_GCC_CNTR="gcc14-tools"
_CNTR_ARGS=""

if isMac; then
    _CNTR_ARGS="--security-opt=seccomp=unconfined"
fi

# Fire up the build container, mounting the project folder.
alias run-gcc14="${CNTR_TECH} run \
          --volume=${_CPP_BOOTSTRAP_HOME}:/work \
          --workdir=/work \
          --detach -it \
          --cap-add=SYS_PTRACE \
          --no-healthcheck \
          ${_CNTR_ARGS} \
          --name ${_GCC_CNTR} ${_GCC_IMG}"

alias bt="${CNTR_TECH} exec -it -w /work/\$(basename \$(pwd))              ${_GCC_CNTR}"
alias bd="${CNTR_TECH} exec -it -w /work/\$(basename \$(pwd))/_build/debug ${_GCC_CNTR}"
alias bp="${CNTR_TECH} exec -it -w /work/\$(basename \$(pwd))/_build/prod  ${_GCC_CNTR}"
alias bbash="echo 'Use ctrl-p ctrl-q to quit'; ${CNTR_TECH} exec -it -w /work/\$(basename \$(pwd)) ${_GCC_CNTR} bash"

unset _GCC_IMG
unset _GCC_CNTR
unset _CNTR_ARGS
unset _CPP_BOOTSTRAP_HOME
