# -----------------------------------------------------------------
#
# Submake to run unit tests
#
# -----------------------------------------------------------------

ifndef _INCLUDE_UNIT_TEST_CPP_MAK
_INCLUDE_UNIT_TEST_CPP_MAK := 1

ifndef D_BLD
    $(error parent makefile must define 'D_BLD')
endif
ifndef D_BLD_DEBUG
    $(error cpp.mak must define 'D_BLD_DEBUG')
endif
ifndef D_BLD_PROD
    $(error cpp.mak must define 'D_BLD_PROD')
endif
ifndef DEFAULT_BUILD_TYPE
    $(error cpp.mak must define 'DEFAULT_BUILD_TYPE')
endif

# This is relative to D_BLD folder, so no D_BLD prefix
_UT_REPORT := utest-results/unit-test-results.xml

# ------------ C++ Unit Test Invocation Section ------------

ifeq "$(DEFAULT_BUILD_TYPE)" "Release"
    unit-test:  unit-test-prod
    unit-tests: unit-test-prod
else ifeq "$(DEFAULT_BUILD_TYPE)" "Debug"
    unit-test:  unit-test-debug
    unit-tests: unit-test-debug
else
    $(error bad value for DEFAULT_BUILD_TYPE: "$(DEFAULT_BUILD_TYPE)")
endif

unit-test-prod: _ARG_BLD_DIR := $(D_BLD_PROD)
unit-test-prod: _utp

unit-test-debug: _ARG_BLD_DIR := $(D_BLD_DEBUG)
unit-test-debug: _utd

unit-test-both: unit-test-debug unit-test-prod

# Run unit tests by invoking the CMake ctest utility
# so we get results in standard xml format.
#
_utp _utd:
	$(CPP_BLD_CNTR_EXEC) ctest --test-dir $(_ARG_BLD_DIR) \
	    --output-junit ${_UT_REPORT}
	@echo "Find unit test results in $(_ARG_BLD_DIR)/$(_UT_REPORT)"

.PHONY: unit-test      unit-tests \
        unit-test-prod unit-test-debug \
        unit-test-both _utp _utd

# ------------ Help Section ------------

HELP_TXT += "\n\
unit-test,       Run unit tests for default build\n\
unit-tests,      Same as unit-test singular\n\
unit-test-prod,  Run unit tests for prod build\n\
unit-test-debug, Run unit tests for debug build\n\
unit-test-both,  Run unit tests for prod and debug\n\
"

endif
