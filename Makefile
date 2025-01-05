# -------------------------------------------------------
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
# End Section
#
# -------------------------------------------------------

TOP      := .
D_MAIN   := $(TOP)/main
D_DOCS   := $(TOP)/docs
D_TOOLS  := $(TOP)/tools
D_SRC    := $(TOP)/src
D_BLD  	 := $(TOP)/_build
D_MAK    := $(D_TOOLS)/submakes
D_SCP    := $(D_TOOLS)/scripts
D_CONAN  := $(D_TOOLS)/conan
D_CNTRS  := $(D_TOOLS)/containers
APP_NAME := RedFlame

all: all-relay

include $(D_MAK)/container-tech.mak
include $(D_MAK)/version-vars.mak
include $(D_MAK)/cpp.mak
include $(D_MAK)/conan.mak
include $(D_MAK)/cpp-unit-test.mak
include $(D_MAK)/cpp-code-coverage.mak
include $(D_MAK)/cpp-static-analysis.mak
include $(D_MAK)/release-tarball.mak
include $(D_CNTRS)/containers.mak
include $(D_MAK)/spelling.mak
include $(D_MAK)/print-debug.mak
include $(D_MAK)/help.mak
include $(D_DOCS)/docs.mak

# include $(D_MAK)/uncrustify.mak

all-relay: app

.PHONY: all all-relay

# ------------ Help Section ------------

HELP_TXT += "\n\
all,   Build the repo\n\
"
