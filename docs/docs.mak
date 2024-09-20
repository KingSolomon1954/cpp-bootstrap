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

docs: docs-prep-out docs-png docs-sphinx docs-doxygen

# Dependencies for doc targest

docs-png: docs-png-cmd

docs-sphinx: docs-png docs-sphinx-cmd

docs-doxygen: docs-sphinx docs-doxygen-cmd

docs-clean:
	rm -rf $(DOCS_OUT)

# Always remove and then recreate docs tree
# so to catch deleted files between runs.
#
docs-prep-out:
	rm -rf   $(DOCS_OUT)
	mkdir -p $(DOCS_OUT)

.PHONY: docs          docs-png     \
        docs-clean    docs-doxygen \
        docs-prep-out docs-sphinx 

include $(D_MAK)/docs-sphinx.mak
include $(D_MAK)/docs-doxygen.mak
include $(D_MAK)/docs-plantuml.mak
include $(D_MAK)/docs-publish.mak

# ------------ Help Section ------------

HELP_TXT += "\n\
docs,         Build docs\n\
docs-clean,   Deletes generated docs\n\
docs-doxygen, Generate only C++ API docs\n\
docs-sphinx,  Generate only Sphinx docs\n\
docs-png,     Generate only PNG files\n\
"
endif
