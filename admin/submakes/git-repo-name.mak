# -----------------------------------------------------------------
#
# Submake to define variable that obtains git repo name
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_GIT_REPO_NAME_MAK
_INCLUDE_GIT_REPO_NAME_MAK := 1

GIT_REPO_NAME = "$(basename $(notdir $(shell git config --get remote.origin.url)))"

endif
