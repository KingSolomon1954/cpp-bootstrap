#!/bin/bash
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

makeEnvVarName()    # $1 is suffix
{
    # For example, if CONAN_REGISTRY = conan.io and $1 = "_PAT" 
    # then returns "CONAN_IO_PAT"
    
    local name=${regyName/"."/"_"}  # conan.io --> conan_io
    name=${name/"-"/"_"}            # conan-io --> conan_io
    name=${name^^}                  # convert to uppercase
    name=${name}$1                  # add suffix
    echo ${name}
}

# ---------------------------------------------------------------------

promptForUsernameToken()
{
    read -p "(${CONAN_REGISTRY}) Username: " uname
    echo "${uname}"
    # Maybe default to LOGNAME if user just presses enter
    # echo "Default = ${LOGNAME}"
    # Use LOGNAME if user enters empty
    # if [ -z "${uname}" ]; then
    #     uname=${LOGNAME}
    # fi
}

# ---------------------------------------------------------------------

promptForUrl()
{
    read -p "(${CONAN_REGISTRY}) URL: " url
    echo "${url}"
}

# ---------------------------------------------------------------------

promptForRegistryToken()
{
    read -s -p "(${CONAN_REGISTRY}) Password: " passwd
    echo "${passwd}"
}

# ---------------------------------------------------------------------

getValueFromFile()    # $1 is file name
{
    if [ -f $1 ]; then
        cat $1
    else
        echo ""
    fi
}

# ---------------------------------------------------------------------

getUsernameToken()
{
    local usernameFileName="${HOME}/.ssh/${regyName}-username"
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
    local tokenFileName="${HOME}/.ssh/${regyName}-token"
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

# ---------------------------------------------------------------------

registryAdd()
{
    if conanHaveRegistry ${CNTR_TECH} ${regyName} ${BLD_CNTR_NAME}; then
        echo "(conan) Conan already has registry: ${regyName}, no action"
        return 0    # return success
    fi
    
    echo "(conan) Adding Conan registry: ${regyName}"
    conanAddRegistry ${CNTR_TECH} ${regyName} ${BLD_CNTR_NAME} ${regyUrl}
}

# ---------------------------------------------------------------------

registryEnable()
{
    if [ ${doEnable} = "yes" ]; then
        conanEnableRegistry ${CNTR_TECH} ${regyName} ${BLD_CNTR_NAME}
    else
        conanDisableRegistry ${CNTR_TECH} ${regyName} ${BLD_CNTR_NAME}
    fi
}

# ---------------------------------------------------------------------

registryLogin()
{
    if [ ${doLogin} = "yes" ]; then
        if conanIsLoggedIn ${CNTR_TECH} ${regyName} ${BLD_CNTR_NAME}; then
            echo "(conan) Already logged in to ${regyName}"
            return 0   # return success, already logged in
        fi
        echo "(${regyName}) Gathering credentials for Auto-Login"
        getUsernameToken
        getRegistryToken
        # Change or set the username on the registry if different.
        conanSetUsername ${CNTR_TECH} ${regyName} ${BLD_CNTR_NAME} ${USERNAME_TOKEN}
        # Execute login.
        conanLogin ${CNTR_TECH} ${regyName} ${BLD_CNTR_NAME} ${REGISTRY_TOKEN}
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
    echo "Processing ${propFile}"

    initVars
    parseFile
    checkEmptyVars
    printVars
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

# echo ${@:3}
# echo "howie ${REGISTRY_PROPERTY_FILES}"

echo "(conan) Setting up Conan registries"
checkArgs
processFiles
exit 0

# ---------------------------------------------------------------------
