#!/bin/bash
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_PYTHON_TOOLS_NAME=$2
POETRY_REPO_ALIAS=$3

loginPoetryRepository()
{
	${CNTR_TECH} exec ${CNTR_PYTHON_TOOLS_NAME} grep -q http-basic.${POETRY_REPO_ALIAS} /root/.config/pypoetry/auth.toml
	authExists=$?

	# Only try to login if there isn't already a poetry auth file in the container
	if [ $authExists -ne 0 ]; then
		# Check to see if the pypi repo login details were already provided in the environment
		if [[ -z ${PYPI_REPO_USERNAME} || -z ${PYPI_REPO_PASSWORD} ]]; then
			echo "Login to PyPi Repo"
			read -p "Username: " PYPI_REPO_USERNAME
			read -s -p "Artifactory API Key: " PYPI_REPO_PASSWORD
		fi
		# Attach to the python container and push the login details into poetry's stored credentials
		${CNTR_TECH} exec ${CNTR_PYTHON_TOOLS_NAME} poetry config http-basic.${POETRY_REPO_ALIAS} ${PYPI_REPO_USERNAME} ${PYPI_REPO_PASSWORD}
	fi
}

loginPoetryRepository
