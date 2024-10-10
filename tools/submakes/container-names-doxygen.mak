# -----------------------------------------------------------------
#
# This submake provides standard variables for Doxygen container.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_NAMES_DOXYGEN_MAK
_INCLUDE_CONTAINER_NAMES_DOXYGEN_MAK := 1

CNTR_DOXYGEN_REPO  ?= docker.io
CNTR_DOXYGEN_IMAGE ?= rodrigodornelles/doxygen
# greenbone/doxygen
CNTR_DOXYGEN_VER   ?= latest
CNTR_DOXYGEN_PATH  ?= $(CNTR_DOXYGEN_REPO)/$(CNTR_DOXYGEN_IMAGE):$(CNTR_DOXYGEN_VER)
CNTR_DOXYGEN_NAME  := doxygen

endif
