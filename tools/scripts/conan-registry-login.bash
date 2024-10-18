#!/usr/bin/env bash
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
# checks for env variable <REGISTRY>_PAT      ("-" turned into underscore)
# checks for env variable <REGISTRY>_USERNAME
#
# For example, if container registry is `aws-arty` then looks
# for these environment variables:
#
#   AWS_ARTY_PAT         # personal access token / password
#   AWS_ARTY_USERNAME    # login user name for this registry
#
# Reads credentials (personal access token(PAT) or password and
# user name) from files if found:
#
# checks for access token in file in `~/.ssh/<REGISTRY>-token`
# checks for username file in `~/.ssh/<REGISTRY>-username`
#
# For example, if container registry is `aws-arty` then looks
# for these files:
#
#   $HOME/.ssh/aws-arty-token     # personal access token / password
#   $HOME/.ssh/aws-arty-username  # login user name for this registry
#
# These files have just a single line each. For example:
#
# > cat $HOME/.ssh/aws-arty-username
# ElvisTheDeveloper
# > cat $HOME/.ssh/aws-arty-token
# aws_arty_675b9Jam99721
#
# if no env-var or file, then prompts for PAT/password
# if no env-var or file, then prompts for username
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
BLD_CNTR_NAME=$2
CONAN_REGISTRY=$3

# Where to find lib-conan-registry script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-conan-registry.bash

if [ -z ${CONAN_REGISTRY} ]; then
    echo "${0}: Missing argument 2, CONAN_REGISTRY must be supplied"
    exit 1   # exit error
fi

if [ -z ${BLD_CNTR_NAME} ]; then
    echo "${0}: Missing argument 3, Name of build container must be supplied"
    exit 1   # exit error
fi

echo "(${CONAN_REGISTRY}) Logging into Conan registry: ${CONAN_REGISTRY}"

conanLogin ${CNTR_TECH} ${BLD_CNTR_NAME} ${CONAN_REGISTRY}

# ---------------------------------------------------------------------
