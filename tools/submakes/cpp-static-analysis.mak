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
ifndef D_SRC
    $(error Parent makefile must define 'D_SRC')
endif
ifndef D_TOOLS
    $(error Parent makefile must define 'D_TOOLS')
endif
ifndef APP_NAME
    $(error Parent makefile must define 'APP_NAME')
endif
ifndef VERSION_TRIPLET
    $(error Parent makefile must define 'VERSION_TRIPLET')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-cppcheck.mak
include $(D_MAK)/git-repo-name.mak

# ------------ Setup Section ------------

_D_SRCS  := $(D_SRC)/main/src \
            $(D_SRC)/main/include \
            $(D_SRC)/lib-gen/src \
            $(D_SRC)/lib-gen/include \
            $(D_SRC)/lib-codec/src \
            $(D_SRC)/lib-codec/include

# Using STA as the mnemonic for static analysis

_STA_DIR           := $(D_BLD)/static-analysis
_D_STA_FILES       := $(D_BLD)/static-analysis/files
_D_STA_REPORT      := $(D_BLD)/static-analysis/report
_STA_INDEX_FILE    := $(D_BLD)/static-analysis/report/index.html
_STA_RESULTS_FILE  := $(D_BLD)/static-analysis/files/results.xml
_STA_SUPPRESS_FILE := $(D_TOOLS)/static-analysis/suppression-list.txt
_STA_HELP_FILE     := $(D_MAK)/help-files/help-cpp-static-analysis
_STA_BADGE_FILE    := $(D_BLD)/static-analysis/report/static-analysis-badge.yml

# ------------ Repo Analysis Section ------------

static-analysis: static-analysis-report

static-analysis-report: $(_STA_INDEX_FILE)

$(_STA_INDEX_FILE): $(_STA_RESULTS_FILE)
	$(CNTR_TECH) run --rm \
	    --volume $(PWD):/work \
	    --entrypoint cppcheck-htmlreport \
	    $(CNTR_CPPCHECK_TOOLS_PATH) \
	    --title="$(APP_NAME)-v$(VERSION_TRIPLET)" \
	    --file=/work/$(_STA_RESULTS_FILE) \
	    --source-dir=/work/$(_D_STA_FILES) \
	    --report-dir=/work/$(_D_STA_REPORT)
	@echo "Creating badge file"
	@value=$$(grep --count '<error>' $(_STA_RESULTS_FILE)); \
	echo "badge:" > $(_STA_BADGE_FILE); \
	echo "  error-count: $${value}" >> $(_STA_BADGE_FILE)

$(_STA_RESULTS_FILE): _create-sta_dirs
	$(CNTR_TECH) run --rm \
	    --volume $(PWD):/work \
	    $(CNTR_CPPCHECK_TOOLS_PATH) \
	    --template=gcc --xml \
	    --suppressions-list=/work/$(_STA_SUPPRESS_FILE) \
	    --cppcheck-build-dir=/work/$(_D_STA_FILES) \
	    --output-file=/work/$(_STA_RESULTS_FILE) \
	    $(addprefix /work/,$(_D_SRCS))

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
