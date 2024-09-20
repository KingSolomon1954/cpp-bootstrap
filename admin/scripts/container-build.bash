#!/bin/bash
#
# Starts a Docker/Podman build on a specified Dockerfile and root context with
# optional build arguments and tags for the resulting container image.
# Additionally, this script allows for extra features to be toggled with
# the last input parameter.
#
# Extra Features Supported:
#  - requires-conan: Enables prompting the user for conan login credentials 
#		     that will be used during the docker build
#  - requires-pypi: Enables prompting the user for pypi login credentials
#		     or artifactory API key that can be used during docker build
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_DOCKERFILE=$2
CNTR_BUILD_ROOT=$3
CNTR_EXTRA_FEATURES=$4
CNTR_BUILD_ARGS=("${@:5}")


startContainerBuild()
{
	_API_KEY_FILE=${HOME}/.ssh/aws-artifactory-api-key.txt

	# Check to see if we were requested to process anything extra
	# - Process conan login credentials so we can pass them into the docker build environment 
	if [[ ${CNTR_EXTRA_FEATURES} == *"requires-conan"* ]]; then
	
		# Check to see if the conan login details were already provided in the environment
		if [ -f ${_API_KEY_FILE} ]; then
			echo "Auto-login using ${_API_KEY_FILE}"
			CONAN_LOGIN_USERNAME="${LOGNAME}"
			CONAN_PASSWORD="$(cat ${_API_KEY_FILE})"
		elif [[ -z ${CONAN_LOGIN_USERNAME} || -z ${CONAN_PASSWORD} ]]; then
			echo "Login to Conan Repo"
			read -p "Username: " CONAN_LOGIN_USERNAME
			read -s -p "Artifactory API Key: " CONAN_PASSWORD
		fi
	
		# Add the CONAN credentials as additional build args
		CNTR_BUILD_ARGS+=(--build-arg CONAN_LOGIN_USERNAME="${CONAN_LOGIN_USERNAME}")
		CNTR_BUILD_ARGS+=(--build-arg CONAN_PASSWORD="${CONAN_PASSWORD}")
	fi
	
	# - Process pypi login credentials so we can pass them into the docker build environment 
	if [[ ${CNTR_EXTRA_FEATURES} == *"requires-pypi"* ]]; then

		# Check to see if the pypi login details were already provided in the environment
		if [ -f ${_API_KEY_FILE} ]; then
			echo "Auto-login using ${_API_KEY_FILE}"
			PYPI_USERNAME="${LOGNAME}"
			PYPI_API_KEY="$(cat ${_API_KEY_FILE})"
		elif [[ -z ${PYPI_USERNAME} || -z ${PYPI_API_KEY} ]]; then
			echo "Login to PyPI Repo"
			read -p "Username: " PYPI_USERNAME
			read -s -p "Artifactory API Key: " PYPI_API_KEY
		fi
	
		# Add the PYPI credentials as additional build args
		CNTR_BUILD_ARGS+=(--build-arg PYPI_USERNAME="${PYPI_USERNAME}")
		CNTR_BUILD_ARGS+=(--build-arg PYPI_API_KEY="${PYPI_API_KEY}")
	fi

	# Run the container build
	${CNTR_TECH} build "${CNTR_BUILD_ARGS[@]}" -f ${CNTR_DOCKERFILE} ${CNTR_BUILD_ROOT}
}

startContainerBuild
