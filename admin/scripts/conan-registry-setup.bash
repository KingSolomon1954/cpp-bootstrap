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
    local key=${line%% *}; # echo "key = ${key}"
    local val=${line##* }; # echo "val = ${val}"
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
    echo "name: ${regyName}"
    echo "url: ${regyUrl}"
    echo "login: ${doLogin}"
    echo "enable: ${doEnable}"
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

processOneFile()
{
    local propFile=$1
    echo "Processing ${propFile}"
    if [ ! -f ${propFile} ]; then
        echo "${0}: Error: no such file: ${propFile}"
        exit 1    # error
    fi

    initVars
    
    while read line; do
        parseLine
    done < ${propFile}
    
    checkEmptyVars
    printVars
    registryAdd
    registryEnable
    registryLogin
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

checkArgs
processFiles
exit 0


# ---------------------------------------------------------------------

makeEnvVarName()    # $1 is suffix
{
    # For example, if CONAN_REGISTRY = conan.io and $1 = "_PAT" 
    # then returns "CONAN_IO_PAT"
    
    local name=${CONAN_REGISTRY/"."/"_"}  # conan.io --> conan_io
    name=${name/"-"/"_"}                  # conan-io --> conan_io
    name=${name^^}                        # convert to uppercase
    name=${name}$1                        # add suffix
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

getRegistryToken()
{
    local tokenFileName="${HOME}/.ssh/${CONAN_REGISTRY}-token"
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

getUsernameToken()
{
    local usernameFileName="${HOME}/.ssh/${CONAN_REGISTRY}-username"
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

getRegistryUrl()
{
    local urlFileName="${HOME}/.ssh/${CONAN_REGISTRY}-url"
    local urlEnvVarUrl=$(makeEnvVarName "_URL")
    declare -n urlEnvVarValue=${urlEnvVarUrl}

    local registryUrl=${urlEnvVarValue}
    if [ -z "${registryUrl}" ]; then
        echo "(url) Checking env-var \"${urlEnvVarUrl}\", not found"
        registryUrl=$(getValueFromFile ${urlFileName})
        if [ -z "${registryUrl}" ]; then
            echo "(url) Checking file \"${urlFileName}\", not found"
        else
            echo "(url) Checking file \"${urlFileName}\", found"
        fi
    else
        echo "(url) Checking env-var \"${urlEnvVarUrl}\", found"
    fi
    if [ -z "${registryUrl}" ]; then
        registryUrl=$(promptForUrl)
    fi
    REGISTRY_URL=${registryUrl}
}

# ---------------------------------------------------------------------

checkHaveRegistry()
{
    if conanHaveRegistry ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME}; then
        return 0    # Yes, have it.
    fi
    
    echo "(${CONAN_REGISTRY}) Adding Conan registry: ${CONAN_REGISTRY}"
    getRegistryUrl
    conanAddRegistry ${CNTR_TECH} ${CONAN_REGISTRY} \
                     ${BLD_CNTR_NAME} ${REGISTRY_URL}
}

# ---------------------------------------------------------------------

checkAlreadyLoggedIn()
{
    if conanIsLoggedIn ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME}; then
        echo "(${CONAN_REGISTRY}) Already logged in to ${CONAN_REGISTRY}"
        exit 0   # exit success, already logged in
    fi
}

# ---------------------------------------------------------------------

doLogin()
{
    # Change or set the username on the registry if different.
    conanSetUsername ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME} ${USERNAME_TOKEN}

    # Execute login.
    conanLogin ${CNTR_TECH} ${CONAN_REGISTRY} ${BLD_CNTR_NAME} ${REGISTRY_TOKEN}
}

# ---------------------------------------------------------------------

echo "(conan) Setting up Conan registries"
checkArgs
checkHaveRegistry                  # Adds registry if missing
checkAlreadyLoggedIn               # Exits script if already logged in
echo "(${CONAN_REGISTRY}) Gathering credentials for Auto-Login"
getUsernameToken
getRegistryToken
doLogin

# ---------------------------------------------------------------------
