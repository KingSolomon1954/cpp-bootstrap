# -----------------------------------------------------------------
#
# This submake provides standard variables for Sphinx
# documentation generator.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_SPHINX_NAMES_MAK
_INCLUDE_CONTAINER_SPHINX_NAMES_MAK := 1

CNTR_SPHINX_IMAGE ?= kingsolomon1954/containers/sphinx
CNTR_SPHINX_VER   ?= 7.3.7
CNTR_SPHINX_REPO  ?= ghcr.io
CNTR_SPHINX_PATH  ?= $(CNTR_SPHINX_REPO)/$(CNTR_SPHINX_IMAGE):$(CNTR_SPHINX_VER)
CNTR_SPHINX_NAME  := sphinx

endif
