#!/usr/bin/env bash
#
# File: docs-publish.bash
#
# ---------------------------------------------------------------------
#
# Publishing docs means copying all the files under _build/site
# to the docs/site folder, where they will be checked-in.
# GitHub is setup to treat the docs/site folder as a static website.
#
# However, there are two complications. If a developer has not yet run a
# code coverage report or static analysis, there will be a placeholder
# code coverage file and/or a placeholder static analysis file. In these
# cases we want to avoid overwritting any existing published code
# coverage report or static analysis report if they exist. This is a
# normal and expected workflow. It is quite reasonable for a developer
# to want to publish docs without being forced to run code coverage or
# static analysis. And doing so should not overwrite or lose any
# previously published reports.
#
# ---------------------------------------------------------------------

DOCS_OUT=$1           # _build/site
DOCS_PUB=$2           # docs/site
DOCS_TMP=_build/tmp

# ---------------------------------------------------------------------

checkArgs()
{
    if [ $# -ne 2 ]; then
        echo "${0}: Expecting 2 args, only got one ${#}"
        exit 1   # exit error
    fi
    if [ ! -d ${DOCS_OUT} ]; then
        echo "${0}: DOCS_OUT not exists or not a directory: ${DOCS_OUT}"
        exit 1   # exit error
    fi
    if [ ! -d ${DOCS_PUB} ]; then
        echo "${0}: DOCS_PUB not exists or not a directory: ${DOCS_PUB}"
        exit 1   # exit error
    fi
}

# ---------------------------------------------------------------------

needPreserveCodeCoverage()
{
    if [ $(ls ${DOCS_OUT}/code-coverage/html | wc -w) -eq 1 -a \
         $(ls ${DOCS_PUB}/code-coverage/html | wc -w) -gt 1 ]; then
        return 0    # return true, yes need to preserve
    fi
    return 1        # return false, no need to preserve
}

# ---------------------------------------------------------------------

needPreserveStaticAnalysis()
{
    if [ $(ls ${DOCS_OUT}/static-analysis/report | wc -w) -eq 1 -a \
         $(ls ${DOCS_PUB}/static-analysis/report | wc -w) -gt 1 ]; then
        return 0    # return true, yes need to preserve
    fi
    return 1        # return false, no need to preserve
}

# ---------------------------------------------------------------------

doPreserveCodeCoverage()
{
    if ! needPreserveCodeCoverage; then
        return    # not preserving
    fi
    # Preserve code-coverage contents in tmp
    preserveCodeCoverage="true"
    rm -rf   ${DOCS_TMP}/code-coverage
    cp -p -r ${DOCS_PUB}/code-coverage/ ${DOCS_TMP}/
}

# ---------------------------------------------------------------------

doPreserveStaticAnalysis()
{
    if ! needPreserveStaticAnalysis; then
        return    # not preserving
    fi
    # Preserve static-analysis contents in tmp
    preserveStaticAnalysis="true"
    rm -rf   ${DOCS_TMP}/static-analysis
    cp -p -r ${DOCS_PUB}/static-analysis/ ${DOCS_TMP}/
}

# ---------------------------------------------------------------------

doRestoreCodeCoverage()
{
    if [ -z "${preserveCodeCoverage}" ]; then
        return    # not preserving
    fi
     # Restore code-coverage contents from tmp
    rm -rf ${DOCS_PUB}/code-coverage
    mv     ${DOCS_TMP}/code-coverage/ ${DOCS_PUB}/
}

# ---------------------------------------------------------------------

doRestoreStaticAnalysis()
{
    if [ -z "${preserveStaticAnalysis}" ]; then
        return    # not preserving
    fi
     # Restore static-analysis contents from tmp
    rm -rf ${DOCS_PUB}/static-analysis
    mv     ${DOCS_TMP}/static-analysis/ ${DOCS_PUB}/
}

# ---------------------------------------------------------------------

echo "Publishing docs to ${DOCS_PUB}"

checkArgs $*
rm -rf ${DOCS_TMP}; mkdir -p ${DOCS_TMP}

doPreserveCodeCoverage
doPreserveStaticAnalysis

# Safe now to replace docs/site with _build/site
rm -rf ${DOCS_PUB}/*
mkdir -p ${DOCS_PUB}
cp -p -r ${DOCS_OUT}/* ${DOCS_PUB}/
touch ${DOCS_PUB}/.nojekyll

doRestoreCodeCoverage
doRestoreStaticAnalysis

# ---------------------------------------------------------------------
