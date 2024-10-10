# -----------------------------------------------------------------
#
# Provides standard variables for the GCC 11 build container.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_NAMES_GCC_11_MAK
_INCLUDE_CONTAINER_NAMES_GCC_11_MAK := 1

CNTR_GCC_11_TOOLS_REPO  := localhost
CNTR_GCC_11_TOOLS_IMAGE := gcc11-tools
CNTR_GCC_11_TOOLS_VER   := latest
CNTR_GCC_11_TOOLS_PATH  := $(CNTR_GCC_11_TOOLS_REPO)/$(CNTR_GCC_11_TOOLS_IMAGE):$(CNTR_GCC_11_TOOLS_VER)
CNTR_GCC_11_TOOLS_NAME  := gcc11-tools

endif
