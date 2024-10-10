# -----------------------------------------------------------------
#
# This submake provides standard variables for spelling container.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_SPELLING_NAMES_MAK
_INCLUDE_CONTAINER_SPELLING_NAMES_MAK := 1

CNTR_SPELLING_REPO  ?= docker.io
CNTR_SPELLING_IMAGE ?= tmaier/hunspell
CNTR_SPELLING_VER   ?= latest
CNTR_SPELLING_PATH  ?= $(CNTR_SPELLING_REPO)/$(CNTR_SPELLING_IMAGE):$(CNTR_SPELLING_VER)
CNTR_SPELLING_NAME  := hunspell

endif
