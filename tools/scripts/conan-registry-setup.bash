#!/usr/bin/env bash
#
# File: conan-registry-setup.bash
#
# ---------------------------------------------------------------------

# Where to find lib-conan-registry script.
# Will be co-located with this script.
tmp1=${0%/}         # grab directory path of this script
dirName=${tmp1%/*}  # remove last level in path

source ${dirName}/lib-conan-registry.bash

# ---------------------------------------------------------------------

checkArgs()
{
    if [ -z ${CNTR_TECH} ]; then
        echo "${0}: Missing argument 1, CNTR_TECH must be supplied"
        exit 1   # exit error
    fi

    if [ -z ${BLD_CNTR_NAME} ]; then
        echo "${0}: Missing argument 2, Name of build container must be supplied"
        exit 1   # exit error
    fi

    if [ -z "${REGISTRY_PROPERTY_FILES}" ]; then
        echo "${0}: Missing arguments, registry property files must be supplied"
        exit 1   # exit error
    fi
}

# ---------------------------------------------------------------------

parseLine()
{
    local key=${line%% *}; # grab up to first space
    local val=${line##* }; # grab after first space
    case ${key} in
        "name:")     regyName=${val};;
        "url:")      regyUrl=${val};;
        "login:")    doLogin=${val};   checkYesNo ${val};;
        "enable:")   doEnable=${val};  checkYesNo ${val};;
        "publish:")  doPublish=${val}; checkYesNo ${val};;
        *)           echo "${0}: Error processing: \"${propFile}\": unrecognized key: \"${line}\"";
                     exit 1;;
    esac
}

# ---------------------------------------------------------------------

initVars()
{
    regyName=""
    regyUrl=""
    doLogin=""
    doEnable=""
    doPublish=""
}

# ---------------------------------------------------------------------

printVars()
{
    echo "name:    ${regyName}"
    echo "url:     ${regyUrl}"
    echo "login:   ${doLogin}"
    echo "enable:  ${doEnable}"
    echo "publish: ${doPublish}"
}

# ---------------------------------------------------------------------

checkEmptyVars()
{
    local booboo=false
    if [ -z ${regyName} ]; then
        echo "${0}: Error processing: \"${propFile}\": missing entry for: \"name: \"";
        booboo=true
    fi
    if [ -z ${regyUrl} ]; then
        echo "${0}: Error processing: \"${propFile}\": missing entry for: \"url: \"";
        booboo=true
    fi
    if [ -z ${doLogin} ]; then
        echo "${0}: Error processing: \"${propFile}\": missing entry for: \"login: \"";
        booboo=true
    fi
    if [ -z ${doEnable} ]; then
        echo "${0}: Error processing: \"${propFile}\": missing entry for: \"enable: \"";
        booboo=true
    fi
    if [ -z ${doPublish} ]; then
        echo "${0}: Error processing: \"${propFile}\": missing entry for: \"publish: \"";
        booboo=true
    fi
    if [ ${booboo} == "true" ]; then exit 1; fi
}

# ---------------------------------------------------------------------

checkYesNo()
{
    if [[ $1 != "yes" && $1 != "no" ]]; then
        echo "${0}: Error processing: \"${propFile}\": bad value: \"$1\"";
        exit 1
    fi
}

# ---------------------------------------------------------------------

registryAdd()
{
    echo "(conan) Adding Conan registry: ${regyName}"
    if conanHaveRegistry ${CNTR_TECH} ${BLD_CNTR_NAME} ${regyName}; then
        echo "(conan) Conan registry already added: ${regyName}, no action"
        return 0    # return success
    fi
    conanAddRegistry ${CNTR_TECH} ${BLD_CNTR_NAME} ${regyName} ${regyUrl}
}

# ---------------------------------------------------------------------

registryEnable()
{
    if [ ${doEnable} = "yes" ]; then
        if ! conanIsRegistryEnabled ${CNTR_TECH} ${BLD_CNTR_NAME} ${regyName}; then
            conanEnableRegistry ${CNTR_TECH} ${BLD_CNTR_NAME} ${regyName}
        fi
    else
        if conanIsRegistryEnabled ${CNTR_TECH} ${BLD_CNTR_NAME} ${regyName}; then
            conanDisableRegistry ${CNTR_TECH} ${BLD_CNTR_NAME} ${regyName}
        fi
    fi
}

# ---------------------------------------------------------------------

registryLogin()
{
    if [ ${doLogin} = "yes" ]; then
        conanLogin ${CNTR_TECH} ${BLD_CNTR_NAME} ${regyName}
    fi
}

# ---------------------------------------------------------------------

parseFile()
{
    while read line; do
        parseLine
    done < ${propFile}
}

# ---------------------------------------------------------------------

processOneFile()
{
    local propFile=$1
    # echo "Processing ${propFile}"

    initVars
    parseFile
    checkEmptyVars
    # printVars
    registryAdd
    registryLogin
    registryEnable
}

# ---------------------------------------------------------------------

processFiles()
{
    for f in ${REGISTRY_PROPERTY_FILES}; do
        processOneFile "$f"
    done
}

# ---------------------------------------------------------------------

CNTR_TECH=$1
BLD_CNTR_NAME=$2
REGISTRY_PROPERTY_FILES="${@:3}"

echo "(conan) Adding Conan registries"
checkArgs
processFiles

# ---------------------------------------------------------------------
