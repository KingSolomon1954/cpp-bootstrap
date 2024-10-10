# -----------------------------------------------------------------
#
# Submake for C++ compiles with CMake and Conan
#
# -----------------------------------------------------------------

ifndef _INCLUDE_CPP_MAK
_INCLUDE_CPP_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_SRC
    $(error Parent makefile must define 'D_SRC')
endif

include $(D_MAK)/start-cpp-bld-container.mak

# -------- Build Folders --------

# Tie in with folder layout in conanfile.py
D_BLD_DEBUG := $(D_BLD)/debug
D_BLD_PROD  := $(D_BLD)/prod

# Sentinel files, tie in with Conan init
CONAN_INSTALL_DONE_PROD  := $(D_BLD_PROD)/generators/.init-done
CONAN_INSTALL_DONE_DEBUG := $(D_BLD_DEBUG)/generators/.init-done

# -------- CMake Section --------

$(D_BLD_PROD)/Makefile: $(CONAN_INSTALL_DONE_PROD)
	$(CPP_BLD_CNTR_EXEC) cmake $(D_SRC) \
	    -B $(D_BLD_PROD) \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DCMAKE_TOOLCHAIN_FILE=generators/conan_toolchain.cmake

$(D_BLD_DEBUG)/Makefile: $(CONAN_INSTALL_DONE_DEBUG)
	$(CPP_BLD_CNTR_EXEC) cmake $(D_SRC) \
	    -B $(D_BLD_DEBUG) \
	    -DCMAKE_BUILD_TYPE=Debug \
	    -DCMAKE_TOOLCHAIN_FILE=generators/conan_toolchain.cmake \
	    -DCMAKE_MAP_IMPORTED_CONFIG_DEBUG=RELEASE

#	    -DCMAKE_MAP_IMPORTED_CONFIG_COVERAGE=Release

# Directly invoke cmake's Makefile in prod build folder
_build-it-prod: $(D_BLD_PROD)/Makefile
	$(CPP_BLD_CNTR_EXEC) make -C $(D_BLD_PROD) -j$(PROCS)

# Directly invoke cmake's Makefile in debug build folder
_build-it-debug: $(D_BLD_DEBUG)/Makefile
	$(CPP_BLD_CNTR_EXEC) make -C $(D_BLD_DEBUG) -j$(PROCS)

.PHONY: _build-it-prod _build-it-debug

# -------- Last Build Type Section --------

# This file remembers the default build type (Release or Debug)
DEFAULT_BLD_TYPE_FILE := $(D_BLD)/default-build-type.txt

# Set last build type to a default ahead of reading it from file.
DEFAULT_BUILD_TYPE := Debug

# Read BUILD_TYPE from file if file exists. Sets the DEFAULT_BUILD_TYPE
# var.  If file doesn't exist, then Make executes the target
# $(DEFAULT_BLD_TYPE_FILE) following this ifeq check. The file is created
# with default of "Debug".
#
ifneq ($(findstring clean,$(MAKECMDGOALS)),clean)
    -include $(DEFAULT_BLD_TYPE_FILE)
endif

$(D_BLD):
	@mkdir -p $(D_BLD)

$(DEFAULT_BLD_TYPE_FILE): $(D_BLD)
	@echo "DEFAULT_BUILD_TYPE := Debug" > $@

_set-build-type-prod:
	@echo "DEFAULT_BUILD_TYPE := Release" > $(DEFAULT_BLD_TYPE_FILE)
	@cat $(DEFAULT_BLD_TYPE_FILE)

_set-build-type-debug:
	@echo "DEFAULT_BUILD_TYPE := Debug" > $(DEFAULT_BLD_TYPE_FILE)
	@cat $(DEFAULT_BLD_TYPE_FILE)

_set-build-type-show:
	@cat $(DEFAULT_BLD_TYPE_FILE)

set-prod: _set-build-type-prod

set-debug: _set-build-type-debug

set-show: _set-build-type-show

show-default-build: set-show

.PHONY: set-prod set-debug set-show \
        _set-build-type-prod _set-build-type-debug \
        _set-build-type-show show-default-build

# -------- Top Level Targets --------

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    app: prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    app: debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

both:  prod debug

prod:  start-cpp-bld-container _build-it-prod

debug: start-cpp-bld-container _build-it-debug

.PHONY: app both prod debug

# ------------ CPP Clean Section ------------

clean::
	rm -rf $(D_BLD)

clean-prod:
	rm -rf $(D_BLD_PROD)

clean-debug:
	rm -rf $(D_BLD_DEBUG)

.PHONY: clean clean-prod clean-debug

# ------------ Help Section ------------

HELP_TXT += "\n\
app,                Builds the default tree. Initial default is debug\n\
debug,              Builds the debug tree\n\
prod,               Builds the prod tree\n\
both,               Builds both prod and debug\n\
clean,              Deletes $(D_BLD) dir\n\
clean-prod,         Deletes prod build tree\n\
clean-debug,        Deletes debug build tree\n\
set-prod,           Sets default build to prod\n\
set-debug,          Sets default build to debug\n\
show-default-build, Show the default build type\n\
"

endif
