# -----------------------------------------------------------------
#
# Submake to rebuild in debug and run coverage tests.
#
# -----------------------------------------------------------------

ifndef _INCLUDE_CPP_CODE_COVERAGE_MAK
_INCLUDE_CPP_CODE_COVERAGE_MAK := 1

ifndef D_BLD
    $(error parent makefile must define 'D_BLD')
endif
ifndef D_BLD_DEBUG
    $(error cpp.mak must define 'D_BLD_DEBUG')
endif
ifndef DEFAULT_BUILD_TYPE
    $(error cpp.mak must define 'DEFAULT_BUILD_TYPE')
endif

_D_CVG      := $(D_BLD_DEBUG)/coverage
_CVG_REPORT := $(D_BLD_DEBUG)/coverage/index.html
_CVG_BADGE  := $(D_BLD_DEBUG)/coverage/code-coverage-badge.yml

# This is relative to D_BLD folder, so no D_BLD prefix
_CVG_UT_REPORT := coverage/unit-test-run.xml

# ------------ C++ Unit Test Coverage Section ------------
#
# The following "coverage" target sets up to invoke the "coverage"
# target available with CMake. First we reconfigure CMake for a Debug
# build and COVERAGE on. Requires gcov utilities available in the path.
#
code-coverage: debug
	$(CPP_BLD_CNTR_EXEC) cmake $(CMAKE_ARGS) -S $(WORK_TOP)/src -B $(D_BLD_DEBUG) \
	    -DCMAKE_BUILD_TYPE=Debug -DCOVERAGE=ON \
	    -DCoverage_JUNIT_OUTPUT=$(_CVG_UT_REPORT)
	$(CPP_BLD_CNTR_EXEC) make -C $(D_BLD_DEBUG) -j $$(nproc)
	$(CPP_BLD_CNTR_EXEC) make -C $(D_BLD_DEBUG) coverage
	$(D_SCP)/code-coverage-badge.bash $(_CVG_REPORT) $(_CVG_BADGE)
	@echo "Find coverage/profiling results in $(_CVG_REPORT)"
	@echo "Find unit-test run in $(D_BLD_DEBUG)/$(_CVG_UT_REPORT)"

code-coverage-clean:
	rm -rf $(_D_CVG)

.PHONY: code-coverage code-coverage-clean

HELP_TXT += "\n\
code-coverage,       Rebuild w/debug/profiling - run unit tests\n\
code-coverage-clean, Deletes code coverage artifacts\n\
"

endif
