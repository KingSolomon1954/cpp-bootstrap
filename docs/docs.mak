# -------------------------------------------------------
#
# Submake to build auto-documentation targets
#
# -------------------------------------------------------

ifndef _INCLUDE_DOCS_MAK
_INCLUDE_DOCS_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif

ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif

ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif

DOCS_OUT := $(D_BLD)/site
DOCS_SRC := $(D_DOCS)/src

D_IMAGES_SRC := $(DOCS_SRC)/images/src
D_IMAGES_PUB := $(DOCS_SRC)/images/pub

# Develop a list of puml to png files. Wind up with a
# list that looks equivalent to this
# PNGS := \
#	$(D_IMAGES_PUB)/app-processing-flow.png \
#	$(D_IMAGES_PUB)/transformation-class.png
#
PNGS := $(wildcard $(D_IMAGES_SRC)/*.puml)
PNGS := $(PNGS:.puml=.png)
PNGS := $(notdir $(PNGS))
PNGS := $(addprefix $(D_IMAGES_PUB)/, $(PNGS))

# --------- Documenation Targets Section ---------

docs: docs-prep-out docs-png docs-sphinx docs-doxygen \
      docs-code-coverage docs-static-analysis

# Dependencies for doc targest

docs-png: docs-png-cmd

docs-sphinx: docs-png docs-sphinx-cmd

docs-doxygen: docs-sphinx docs-doxygen-cmd

docs-code-coverage: docs-sphinx docs-code-coverage-cmd

docs-static-analysis: docs-sphinx docs-static-analysis-cmd

docs-clean:
	rm -rf $(DOCS_OUT)

# Always remove and then recreate docs tree
# so to catch deleted files between runs.
#
docs-prep-out:
	rm -rf   $(DOCS_OUT)
	mkdir -p $(DOCS_OUT)

.PHONY: docs          	   docs-clean \
        docs-prep-out 	   docs-png \
        docs-sphinx   	   docs-doxygen \
        docs-code-coverage docs-static-analysis

include $(D_MAK)/docs-sphinx.mak
include $(D_MAK)/docs-doxygen.mak
include $(D_MAK)/docs-code-coverage.mak
include $(D_MAK)/docs-static-analysis.mak
include $(D_MAK)/docs-plantuml.mak
include $(D_MAK)/docs-publish.mak

# ------------ Help Section ------------

HELP_TXT += "\n\
docs,          	      Builds all the docs\n\
docs-clean,    	      Deletes generated docs\n\
docs-doxygen,  	      Generates only C++ API docs\n\
docs-code-coverage,   Copies code coverage files into docs tree\n\
docs-static-analysis, Copies static analysis files into docs tree\n\
docs-sphinx,          Generates only Sphinx docs\n\
docs-png,             Generates only PNG files\n\
"
endif
