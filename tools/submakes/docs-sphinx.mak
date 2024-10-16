# -------------------------------------------------------
#
# Submake to build Sphinx docs
#
# -------------------------------------------------------

ifndef _INCLUDE_DOCS_SPHINX_MAK
_INCLUDE_DOCS_SPHINX_MAK := 1

ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif
ifndef DOCS_OUT
    $(error Parent makefile must define 'DOCS_OUT')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-sphinx.mak

_DOCS_SRC := $(D_DOCS)/src

docs-sphinx-cmd:
	# Generating Sphinx docs
	$(CNTR_TECH) run --rm \
	    --user=$(CNTR_USER) \
	    --volume=$$(pwd):/work -it \
	    $(CNTR_SPHINX_TOOLS_PATH) sphinx-build -b html -a \
	    -D release=$(VERSION_TRIPLET) \
	    -D version=$(VERSION_TRIPLET) \
	    --fail-on-warning \
	    --jobs auto \
	    /work/$(_DOCS_SRC) /work/$(DOCS_OUT)

.PHONY: docs-sphinx-cmd

endif
