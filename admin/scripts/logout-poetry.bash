#!/bin/bash
#
# ---------------------------------------------------------------------

CNTR_TECH=$1
CNTR_PYTHON_TOOLS_NAME=$2
POETRY_REPO_ALIAS=$3

logoutPoetryRepository()
{
	${CNTR_TECH} exec ${CNTR_PYTHON_TOOLS_NAME} poetry config http-basic.${POETRY_REPO_ALIAS} --unset
}

logoutPoetryRepository
