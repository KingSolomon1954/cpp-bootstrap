# -----------------------------------------------------------------
#
# Submake rules to run C++ static analysis tool
#
# -----------------------------------------------------------------

ifndef _INCLUDE_CPP_STA_MAK
_INCLUDE_CPP_STA_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_SRCS
    $(error Parent makefile must define 'D_SRCS')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-cppcheck.mak
include $(D_MAK)/git-repo-name.mak

# ------------ Setup Section ------------

# Using STA as the mnemonic for static analysis

_STA_DIR           := $(D_BLD)/static-analysis
_D_STA_FILES       := $(D_BLD)/static-analysis/files
_D_STA_REPORT      := $(D_BLD)/static-analysis/report
_STA_INDEX_FILE    := $(D_BLD)/static-analysis/report/index.html
_STA_RESULTS_FILE  := $(D_BLD)/static-analysis/files/results.xml
_STA_SUPPRESS_FILE := $(D_ADMIN)/static-analysis/suppression-list.txt
_STA_HELP_FILE     := $(D_MAK)/help-files/help-cpp-static-analysis

# ------------ Repo Analysis Section ------------

static-analysis: static-analysis-report

static-analysis-report: $(_STA_INDEX_FILE)

$(_STA_INDEX_FILE): $(_STA_RESULTS_FILE)
	$(CNTR_TECH) run --rm \
	    --volume $(PWD):/work \
	    --entrypoint cppcheck-htmlreport \
	    $(CNTR_CPPCHECK_TOOLS_PATH) \
	    --title=$(GIT_REPO_NAME) \
	    --file=/work/$(_STA_RESULTS_FILE) \
	    --source-dir=/work/$(_D_STA_FILES) \
	    --report-dir=/work/$(_D_STA_REPORT)

$(_STA_RESULTS_FILE): _create-sta_dirs
	$(CNTR_TECH) run --rm \
	    --volume $(PWD):/work \
	    $(CNTR_CPPCHECK_TOOLS_PATH) \
	    --template=gcc --xml \
	    --suppressions-list=/work/$(_STA_SUPPRESS_FILE) \
	    --cppcheck-build-dir=/work/$(_D_STA_FILES) \
	    --output-file=/work/$(_STA_RESULTS_FILE) \
	    $(addprefix /work/,$(D_SRCS))

static-analysis-clean:
	rm -rf $(_STA_DIR)

_create-sta_dirs:
	mkdir -p $(_D_STA_FILES) $(_D_STA_REPORT)

.PHONY: static-analysis static-analysis-clean \
        static-analysis-report _create-sta_dirs

# ------------ Individual File Analysis Section ------------

# Results go to std out, not captured to a file.
# Be aware there's no output if no error.
#
%.sta : %.cpp  _create-sta_dirs
	$(CNTR_TECH) run -t --rm \
	    --volume $(PWD):/work \
	    $(CNTR_CPPCHECK_TOOLS_PATH) \
	    --template=gcc \
	    --suppressions-list=/work/$(_STA_SUPPRESS_FILE) \
            /work/$^

# ------------ Help Section ------------

static-analysis-help: $(_STA_HELP_FILE)
	@$(_STA_HELP_FILE) $(D_MAK)

.PHONY: static-analysis-help

HELP_TXT += "\n\
<filepath>.sta, Runs C++ static analysis on given file\n\
static-analysis,       Runs C++ static analysis against repo\n\
static-analysis-clean, Deletes C++ static analysis artifacts\n\
static-analysis-help,  Displays help for C++ static analysis\n\
"

endif
