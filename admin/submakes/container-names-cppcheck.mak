# -----------------------------------------------------------------
#
# This submake provides standard variables for cppcheck
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_CPPCHECK_NAMES_MAK
_INCLUDE_CONTAINER_CPPCHECK_NAMES_MAK := 1

# CNTR_CPPCHECK_TOOLS_REPO  ?= $(DEFAULT_ART_SGN_REPO)
CNTR_CPPCHECK_TOOLS_REPO  ?= docker.io
CNTR_CPPCHECK_TOOLS_IMAGE ?= neszt/cppcheck-docker
CNTR_CPPCHECK_TOOLS_VER   ?= latest
CNTR_CPPCHECK_TOOLS_PATH  ?= $(CNTR_CPPCHECK_TOOLS_REPO)/$(CNTR_CPPCHECK_TOOLS_IMAGE):$(CNTR_CPPCHECK_TOOLS_VER)
CNTR_CPPCHECK_TOOLS_NAME  ?= cppcheck

endif
