# -------------------------------------------------------
#
# King Solomon Project: Bedrock Library
#
# File: Makefile
#
# Copyright (c) 2024 KingSolomon1954
#
# SPDX-License-Identifier: MIT
#
# -------------------------------------------------------
#
# Start Section
# To get started, issue one of these:
#
#     make help
#     make
#     make debug
#     make prod
#
# The default make is a debug build.
#
# To supply your own args to CMake do something like this:
#
#     make CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Debug"
#
# To run sequential compiles (default is parallel):
#
#    make PROCS=1
#
# ----------- Targets ------------
#
# End Section
#
# -------------------------------------------------------

TOP       := .
D_MAIN    := $(TOP)/main
D_DOCS    := $(TOP)/docs
D_ADMIN   := $(TOP)/admin
D_BLD  	  := $(TOP)/_build
D_MAK     := $(D_ADMIN)/submakes
D_SCP     := $(D_ADMIN)/scripts
D_CONAN   := $(D_ADMIN)/conan
D_CNTRS   := $(D_ADMIN)/containers

all: all-relay

include $(D_MAK)/container-tech.mak
include $(D_MAK)/version-vars.mak
include $(D_MAK)/cpp.mak
include $(D_MAK)/conan.mak
include $(D_MAK)/unit-test-cpp.mak
include $(D_CNTRS)/containers.mak
# include $(D_MAK)/cpp-coverage.mak
# include $(D_MAK)/cpp-static-analysis.mak
# include $(D_MAK)/uncrustify.mak
# include $(D_MAK)/repo-login.mak
# include $(D_MAK)/spelling.mak
# include $(D_MAK)/hack-sh.mak
include $(D_MAK)/print-debug.mak
include $(D_MAK)/help.mak
include $(D_DOCS)/docs.mak

all-relay: app

.PHONY: all all-relay

# ------------ Help Section ------------

HELP_TXT += "\n\
all,   Build the repo\n\
"
