# -----------------------------------------------------------------
#
# Provides standard variables for the GCC 14 build container.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_NAMES_GCC_14_MAK
_INCLUDE_CONTAINER_NAMES_GCC_14_MAK := 1

CNTR_GCC_14_TOOLS_REPO  := ghcr.io/kingsolomon1954/containers
CNTR_GCC_14_TOOLS_IMAGE := gcc14-tools
CNTR_GCC_14_TOOLS_VER   := 14.2.0
CNTR_GCC_14_TOOLS_PATH  := $(CNTR_GCC_14_TOOLS_REPO)/$(CNTR_GCC_14_TOOLS_IMAGE):$(CNTR_GCC_14_TOOLS_VER)
CNTR_GCC_14_TOOLS_NAME  := gcc14-tools

endif
