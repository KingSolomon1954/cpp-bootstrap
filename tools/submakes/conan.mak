# -----------------------------------------------------------------
#
# Submake for using and creating Conan packages
#
# -----------------------------------------------------------------

ifndef _INCLUDE_CONAN_MAK
_INCLUDE_CONAN_MAK := 1

ifndef VERSION_TRIPLET
    $(error Parent makefile must define 'VERSION_TRIPLET')
endif
ifndef D_CONAN
    $(error cpp.mak must define 'D_CONAN')
endif
ifndef D_BLD_DEBUG
    $(error cpp.mak must define 'D_BLD_DEBUG')
endif
ifndef D_BLD_PROD
    $(error cpp.mak must define 'D_BLD_PROD')
endif
ifndef D_MAK
    $(error cpp.mak must define 'D_MAK')
endif
ifndef DEFAULT_BUILD_TYPE
    $(error cpp.mak must define 'DEFAULT_BUILD_TYPE')
endif
ifndef CONAN_INSTALL_DONE_PROD
    $(error cpp.mak must define 'CONAN_INSTALL_DONE_PROD')
endif
ifndef CONAN_INSTALL_DONE_DEBUG
    $(error cpp.mak must define 'CONAN_INSTALL_DONE_DEBUG')
endif

include $(D_MAK)/conan-registry.mak

# ------------ Conan Folders/Files Section ------------

# Locations must agree with CMake setup.
# _build/prod/conan          	   conan install folder
# _build/prod/package  	           conan package folder
# _build/prod/package-verify       conan verify  folder
# _build/debug/conan         	   conan install folder
# _build/debug/package 	           conan package folder
# _build/debug/package-verify      conan verify  folder
_CONAN_INST_PROD        := $(D_BLD_PROD)/generators
_CONAN_PKG_PROD         := $(D_BLD_PROD)/package
_CONAN_PKG_PROD_VERIFY  := $(D_BLD_PROD)/package-verify
_CONAN_INST_DEBUG       := $(D_BLD_DEBUG)/generators
_CONAN_PKG_DEBUG        := $(D_BLD_DEBUG)/package
_CONAN_PKG_DEBUG_VERIFY := $(D_BLD_DEBUG)/package-verify

_CONAN_CFG_DIR := $(D_CONAN)
_CONAN_PY_FILE := $(_CONAN_CFG_DIR)/conanfile.py

# Lockfiles
_CONAN_LOCKFILE_PROD  := $(_CONAN_CFG_DIR)/prod.lock
_CONAN_LOCKFILE_DEBUG := $(_CONAN_CFG_DIR)/debug.lock

_CONAN_REGISTRY := $(CONAN_REGISTRY_FOR_PUBLISHING)

# ------------ Conan Library Name Section ------------
#
# This is for Conan producers.
#
# The following macro defines a shell fragment to obtain the library
# name from conanfile.py. It's used in a couple of rules below. The
# package name is needed when publishing and verifying the package.
#
define _LIB_PKG_NAME_CMD
$$(sed -n "s/^.*name = \"\(.*\)\"/\1/p" $(_CONAN_PY_FILE))
endef

# ------------ Conan Init Section ------------

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    conan: conan-prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    conan: conan-debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

conan-both: conan-prod conan-debug

conan-prod: $(CONAN_INSTALL_DONE_PROD)

conan-debug: $(CONAN_INSTALL_DONE_DEBUG)

$(CONAN_INSTALL_DONE_PROD): _ARG_BLD_TYPE := Release
$(CONAN_INSTALL_DONE_PROD): _ARG_LOCKFILE := $(_CONAN_LOCKFILE_PROD)

$(CONAN_INSTALL_DONE_DEBUG): _ARG_BLD_TYPE := Debug
$(CONAN_INSTALL_DONE_DEBUG): _ARG_LOCKFILE := $(_CONAN_LOCKFILE_DEBUG)

$(CONAN_INSTALL_DONE_DEBUG) $(CONAN_INSTALL_DONE_PROD): \
		$(CONAN_REGISTRY_SETUP_DONE) $(_CONAN_PY_FILE)
	$(CPP_BLD_CNTR_EXEC) conan install \
	    --settings=build_type=$(_ARG_BLD_TYPE) \
	    --lockfile=$(_ARG_LOCKFILE) \
	    $(_CONAN_PY_FILE)
	@touch $@

.PHONY: conan conan-both conan-prod conan-debug

# ------------ Conan Libs Update Section ------------

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    conan-update: conan-update-prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    conan-update: conan-update-debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

conan-update-both: conan-update-prod conan-update-debug

conan-update-prod: _ARG_BLD_TYPE := Release
conan-update-prod: _ARG_INST_DIR := $(_CONAN_INST_PROD)
conan-update-prod: _conan-update1

conan-update-debug: _ARG_BLD_TYPE := Debug
conan-update-debug: _ARG_INST_DIR := $(_CONAN_INST_DEBUG)
conan-update-debug: _conan-update2

_conan-update1 _conan-update2:
	@echo "(conan)  Updating libraries ..."
	@mkdir -p $(_ARG_INST_DIR)
	@$(CPP_BLD_CNTR_EXEC) conan install $(_CONAN_PY_FILE) \
	    --install-folder=$(_ARG_INST_DIR) \
	    --settings=build_type=$(_ARG_BLD_TYPE) \
            --update

.PHONY: conan-update      conan-update-both \
        conan-update-prod conan-update-debug \
        _conan-update1    _conan-update2

# ------------ Conan Lockfile Section ------------

# Important to note that Conan will not raise an error
# during lockfile generation. It will generate the
# lockfile with the best-matching version of the
# dependency package that satisfies the specified
# requirements and constraints, considering the
# available options. Therefore, it is necessary to
# ensure binaries for both debug and release options
# are available before generating a lockfile or the
# lockfile will be incorrect.

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    conan-lock: conan-lock-prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    conan-lock: conan-lock-debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

conan-lock-both: conan-lock-prod conan-lock-debug

conan-lock-prod: _ARG_LOCKFILE := $(_CONAN_LOCKFILE_PROD)
conan-lock-prod: _ARG_BLD_TYPE := Release
conan-lock-prod: _conan-lock1

conan-lock-debug: _ARG_LOCKFILE := $(_CONAN_LOCKFILE_DEBUG)
conan-lock-debug: _ARG_BLD_TYPE := Debug
conan-lock-debug: _conan-lock2

_conan-lock1 _conan-lock2:
	@echo "(conan) Creating Conan lockfile: $(_ARG_LOCKFILE)"
	$(CPP_BLD_CNTR_EXEC) conan lock create $(_CONAN_PY_FILE) \
	    --settings=build_type=$(_ARG_BLD_TYPE) \
	    --lockfile-out=$(_ARG_LOCKFILE)

.PHONY: conan-lock conan-lock-both \
        conan-lock-prod conan-lock-debug \
       _conan-lock1 _conan-lock2

# ------------ Conan Packaging Section ------------

# Packaging consists of several steps
#
# 1. Create a Conan package in a local build folder from already
#    built binaries. Prod and debug have separate package locations.
# 2. Export the Conan package from local workspace folder to the local
#    Conan cache on the build container.
# 3. Verify the package sitting in the cache is a usable library.
# 4. Publish the cached package to Artifactory. This step is normally
#    only performed in CM pipelines.
#
# Therefore invoking conan-pkg runs these targets in this order:
#
#      conan-pkg-package:
#      conan-pkg-export:
#      conan-pkg-verify:

# Fields that make up Conan package versioning/revisions
_CONAN_CHANNEL := development
PULL_BASE_REF  ?= $(shell git branch --show-current)
_CONAN_BRANCH  := $(subst /,-,$(PULL_BASE_REF))

# Obtain source files from here needed to verify a Conan package
_CONAN_PKG_VERIFY_SRC_DIR := $(SRC)/test/test-package

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    conan-pkg: conan-pkg-prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    conan-pkg: conan-pkg-debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

conan-pkg-both: conan-pkg-prod conan-pkg-debug

conan-pkg-prod: conan \
                conan-pkg-package-prod \
                conan-pkg-export-prod \
                conan-pkg-verify-prod

conan-pkg-debug: conan \
                 conan-pkg-package-debug \
                 conan-pkg-export-debug \
                 conan-pkg-verify-debug

.PHONY: conan-pkg conan-pkg-both \
        conan-pkg-prod conan-pkg-debug

# ------------ Conan Package Command Section ------------

# This target runs the Conan package command which in turn runs the
# package() function in conanfile.py, to populate a local workspace
# folder (the package folder) with the resulting package. Note that it
# is the --install-folder=$(_ARG_INST_DIR) argument, which is an input
# to the package command, that distinguishes a debug build from a
# release build.

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    conan-pkg-package: conan-pkg-package-prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    conan-pkg-package: conan-pkg-package-debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

conan-pkg-package-both: conan-pkg-package-prod conan-pkg-package-debug

conan-pkg-package-prod: _ARG_BLD_DIR  := $(BLD_PROD)
conan-pkg-package-prod: _ARG_INST_DIR := $(_CONAN_INST_PROD)
conan-pkg-package-prod: _ARG_PKG_DIR  := $(_CONAN_PKG_PROD)
conan-pkg-package-prod: $(BLD_PROD)/lib _conan-pkg-package1

conan-pkg-package-debug: _ARG_BLD_DIR  := $(BLD_DEBUG)
conan-pkg-package-debug: _ARG_INST_DIR := $(_CONAN_INST_DEBUG)
conan-pkg-package-debug: _ARG_PKG_DIR  := $(_CONAN_PKG_DEBUG)
conan-pkg-package-debug: $(BLD_DEBUG)/lib _conan-pkg-package2

_conan-pkg-package1 _conan-pkg-package2:
	@echo "(conan) running conan-pkg-package"
	$(CPP_BLD_CNTR_EXEC) rm -rf $(_ARG_PKG_DIR)
	$(CPP_BLD_CNTR_EXEC) conan package $(_CONAN_PY_FILE) \
	    --source-folder="." \
	    --build-folder=$(_ARG_BLD_DIR) \
	    --install-folder=$(_ARG_INST_DIR) \
	    --package-folder=$(_ARG_PKG_DIR)

$(D_BLD_DEBUG)/lib $(D_BLD_PROD)/lib:
	$(error "Missing folder "$@" Nothing to package")

conan-pkg-clean:
	$(info "Not supported. Issue make conan-pkg-clean-both, \
	        conan-pkg-clean-prod or conan-pkg-clean-debug")

conan-pkg-clean-both: conan-pkg-clean-prod conan-pkg-clean-debug

conan-pkg-clean-prod:
	rm -rf $(_CONAN_PKG_PROD)

conan-pkg-clean-debug:
	rm -rf $(_CONAN_PKG_DEBUG)

.PHONY: conan-pkg-package conan-pkg-package-both \
        conan-pkg-package-prod conan-pkg-package-debug \
        _conan-pkg-package1 _conan-pkg-package2 \
        conan-pkg-clean-both conan-pkg-clean-prod \
        conan-pkg-clean-debug

# ------------ Conan Export Section ------------

# Exports the package already built on the workspace in the
# package folder to the local Conan cache on the build container

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    conan-pkg-export: conan-pkg-export-prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    conan-pkg-export: conan-pkg-export-debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

conan-pkg-export-both: conan-pkg-export-prod conan-pkg-export-debug

conan-pkg-export-prod: _ARG_INST_DIR := $(_CONAN_INST_PROD)
conan-pkg-export-prod: _ARG_PKG_DIR  := $(_CONAN_PKG_PROD)
conan-pkg-export-prod: _conan-pkg-export1

conan-pkg-export-debug: _ARG_INST_DIR := $(_CONAN_INST_DEBUG)
conan-pkg-export-debug: _ARG_PKG_DIR  := $(_CONAN_PKG_DEBUG)
conan-pkg-export-debug: _conan-pkg-export2

# Exports the package on the workspace to local Conan cache
_conan-pkg-export1 _conan-pkg-export2:
	@echo "(conan) running conan-pkg-export"
	$(CPP_BLD_CNTR_EXEC) conan export-pkg \
	    --install-folder=$(_ARG_INST_DIR) \
	    --package-folder=$(_ARG_PKG_DIR) \
	    --force $(_CONAN_PY_FILE) $(_CONAN_BRANCH)/$(_CONAN_CHANNEL)

.PHONY: conan-pkg-export      conan-pkg-export-both  \
        conan-pkg-export-prod conan-pkg-export-debug \
        _conan-pkg-export1    _conan-pkg-export2

# ------------ Conan Publishing Section ------------

# Publishes the package already in Conan cache on the build
# container to the remote Conan registry.
#
# Note that the Conan cache may contain production, debug or both
# library build types at the same time as they all considered part of
# the very same Conan package version even though the individual
# artifacts came from different folders.
#
conan-pkg-publish:
	$(CPP_BLD_CNTR_EXEC) conan upload \
	    --remote=$(_CONAN_REGISTRY) --all \
	    $(_LIB_PKG_NAME_CMD)/$(VERSION_TRIPLET)@$(_CONAN_BRANCH)/$(_CONAN_CHANNEL) -c

# Removes Conan package from remote Conan registry. 
#
conan-pkg-remove:
	$(CPP_BLD_CNTR_EXEC) conan remove -f --remote=$(_CONAN_REGISTRY) \
	    $(_LIB_PKG_NAME_CMD)/$(VERSION_TRIPLET)

.PHONY: conan-pkg-publish conan-pkg-remove

# ------------ Conan Verify Section ------------

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    conan-pkg-verify: conan-pkg-verify-prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    conan-pkg-verify: conan-pkg-verify-debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

conan-pkg-verify-both: conan-pkg-verify-prod conan-pkg-verify-debug

conan-pkg-verify-prod: _ARG_BLD_TYPE       := Release
conan-pkg-verify-prod: _ARG_PKG_VERIFY_DIR := $(_CONAN_PKG_PROD_VERIFY)
conan-pkg-verify-prod: _conan-pkg-verify1

conan-pkg-verify-debug: _ARG_BLD_TYPE       := Debug
conan-pkg-verify-debug: _ARG_PKG_VERIFY_DIR := $(_CONAN_PKG_DEBUG_VERIFY)
conan-pkg-verify-debug: _conan-pkg-verify2

_conan-pkg-verify1 _conan-pkg-verify2:
	@echo "---------------------------------"
	@echo ""
	@echo "Verifying Conan packaging: ($(_ARG_BLD_TYPE))"
	@echo ""
	@echo "---------------------------------"
	$(CPP_BLD_CNTR_EXEC) bash -c ' \
	    rm -rf $(_ARG_PKG_VERIFY_DIR); \
	    mkdir -p $(_ARG_PKG_VERIFY_DIR); \
	    cp -r $(_CONAN_PKG_VERIFY_SRC_DIR)/* $(_ARG_PKG_VERIFY_DIR); \
	    echo "$(_LIB_PKG_NAME_CMD)/$(VERSION_TRIPLET)@$(_CONAN_BRANCH)/$(_CONAN_CHANNEL)" >> \
	        $(_ARG_PKG_VERIFY_DIR)/conanfile.txt'
	$(CPP_BLD_CNTR_EXEC) conan install \
	    $(_ARG_PKG_VERIFY_DIR)/conanfile.txt \
	    --settings=build_type=$(_ARG_BLD_TYPE) \
	    --install-folder=$(_ARG_PKG_VERIFY_DIR)
	$(CPP_BLD_CNTR_EXEC) cmake \
	    -S $(_ARG_PKG_VERIFY_DIR) \
	    -B $(_ARG_PKG_VERIFY_DIR)
	$(CPP_BLD_CNTR_EXEC) make -C $(_ARG_PKG_VERIFY_DIR)
	@if $(CPP_BLD_CNTR_EXEC) $(_ARG_PKG_VERIFY_DIR)/bin/*; then \
	    echo '---------------------------------';                     \
	    echo ;                                                        \
	    echo 'Conan packaging ($(_ARG_BLD_TYPE)): verified';          \
	    echo ;                                                        \
	    echo '---------------------------------';                     \
	else                                                              \
	    echo '---------------------------------';                     \
	    echo ;                                                        \
	    echo 'Conan packaging ($(_ARG_BLD_TYPE)): failed';            \
	    echo ;                                                        \
	    echo '---------------------------------';                     \
	    exit 2;                                                       \
	fi

.PHONY: conan-pkg-verify      conan-pkg-verify-both \
        conan-pkg-verify-prod conan-pkg-verify-debug \
        _conan-pkg-verify1    _conan-pkg-verify2

# ------------ Conan Misc Section ------------

conan-clear-cache:
	@$(CPP_BLD_CNTR_EXEC) conan remove -f "*"

.PHONY: conan-clear-cache

# ------------ Conan Clean Section ------------

clean::

conan-clean:
	$(info Not supported. Issue make conan-clean-both, conan-clean-prod or conan-clean-debug)

conan-clean-both: conan-clean-prod conan-clean-debug

conan-clean-prod:
	rm -rf $(_CONAN_INST_PROD)

conan-clean-debug:
	rm -rf $(_CONAN_INST_DEBUG)

.PHONY: conan-clean-prod conan-clean-debug conan-clean-both

# ------------ Help Section ------------

HELP_TXT += "\n\
conan,                   Install Conan libs (for default build)\n\
conan-prod,              Install Conan libs for production build\n\
conan-debug,             Install Conan libs for debug build\n\
conan-both,              Install Conan libs for both debug and prod builds\n\
conan-update,            Update Conan libs with latest from remote (default)\n\
conan-update-prod,       Update Conan libs with latest from remote for prod\n\
conan-update-debug,      Update Conan libs with latest from remote for debug\n\
conan-update-both,       Update Conan libs with latest from remote for debug and prod\n\
conan-clean-prod,        Deletes $(_CONAN_INST_PROD) tree\n\
conan-clean-debug,       Deletes $(_CONAN_INST_DEBUG) tree\n\
conan-clean-both,        Deletes both Conan debug and prod tree\n\
conan-clear-cache,       Removes all packages from Conan cache\n\
conan-pkg,               3-steps in one: package/export/verify packaging (default build)\n\
conan-pkg-both,          3-steps in one: package/export/verify packaging for prod and debug\n\
conan-pkg-prod,          3-steps in one: package/export/verify packaging for prod\n\
conan-pkg-debug,         3-steps in one: package/export/verify packaging for debug\n\
conan-pkg-export,        Place package into local Conan cache (default build)\n\
conan-pkg-export-prod,   Place prod package into local Conan cache\n\
conan-pkg-export-debug,  Place debug package into local Conan cache\n\
conan-pkg-export-both,   Place prod and debug packages into local Conan cache\n\
conan-pkg-verify,        Verify package in local cache is usable (default build)\n\
conan-pkg-verify-prod,   Verify prod package in local cache is usable\n\
conan-pkg-verify-debug,  Verify debug package in local cache is usable\n\
conan-pkg-verify-both,   Verify prod and debug package in local cache is usable\n\
conan-pkg-package,       Create package in local folder (default build)\n\
conan-pkg-package-prod,  Create prod package in local folder\n\
conan-pkg-package-debug, Create debug package in local folder\n\
conan-pkg-package-both,  Create prod and debug packages in local folders\n\
conan-pkg-publish,       Write build container's cached package to Artifactory repo\n\
conan-pkg-remove,        Remove package from Conan Artifactory repo\n\
conan-pkg-clean-prod,    Delete $(_CONAN_PKG_PROD) folder\n\
conan-pkg-clean-debug,   Delete $(_CONAN_PKG_DEBUG) folder\n\
conan-pkg-clean-both,    Delete both prod and debug package folders\n\
conan-lock,              Create/update lockfile (default) in $(_CONAN_CFG_DIR)\n\
conan-lock-prod,         Create/update prod lockfile in $(_CONAN_CFG_DIR)\n\
conan-lock-debug,        Create/update debug lockfile in $(_CONAN_CFG_DIR)\n\
conan-lock-both,         Create/update prod and debug lockfile in $(_CONAN_CFG_DIR)\n\
"

endif
