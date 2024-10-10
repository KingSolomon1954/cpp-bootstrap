# -----------------------------------------------------------------
#
# Submake to conditionally start the bld container
#
# -----------------------------------------------------------------

ifndef _INCLUDE_START_CPP_BLD_CONTAINER_MAK
_INCLUDE_START_CPP_BLD_CONTAINER_MAK := 1

ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_SCP
    $(error Parent makefile must define 'D_SCP')
endif

ifdef NO_BLD_CNTR

WORK_TOP := .
CPP_BLD_CNTR_EXEC :=

start-cpp-bld-container:

else

WORK_TOP := /work/$(notdir $(CURDIR))
# Use -it because makefile/scripts need to prompt the user for 
# input at times, plus Conan and CMake will render output in color.
CPP_BLD_CNTR_EXEC = $(CNTR_TECH) exec -it --workdir $(WORK_TOP) $(CNTR_GCC_TOOLS_NAME)

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-gcc14.mak
CNTR_GCC_TOOLS_REPO  := $(CNTR_GCC_14_TOOLS_REPO)
CNTR_GCC_TOOLS_IMAGE := $(CNTR_GCC_14_TOOLS_IMAGE)
CNTR_GCC_TOOLS_VER   := $(CNTR_GCC_14_TOOLS_VER)
CNTR_GCC_TOOLS_PATH  := $(CNTR_GCC_14_TOOLS_PATH)
CNTR_GCC_TOOLS_NAME  := $(CNTR_GCC_14_TOOLS_NAME)

start-cpp-bld-container:
	@$(D_SCP)/start-bld-container.bash \
	    $(CNTR_TECH) "$(CNTR_USER)" \
	    $(CNTR_GCC_TOOLS_REPO) $(CNTR_GCC_TOOLS_PATH) $(CNTR_GCC_TOOLS_NAME) $(DBG_PORT)
endif

.PHONY: start-cpp-bld-container

PROCS ?= $(shell nproc)

# ------------ Help Section ------------

HELP_TXT += "\n\
start-cpp-bld-container, Starts the C++ bld container if necessary\n\
"

endif
