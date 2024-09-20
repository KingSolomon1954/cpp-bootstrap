# -------------------------------------------------------
#
# Submake to build C++ Doxygen API docs
#
# -------------------------------------------------------

ifndef _INCLUDE_DOCS_DOXYGEN_MAK
_INCLUDE_DOCS_DOXYGEN_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef DOCS_SRC
    $(error Parent makefile must define 'DOCS_SRC')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-doxygen.mak

# Strategy is to run Doxygen command from the root folder
# of a repo. Therefore the Doxyfile needs to be configured
# with paths as seen from the root folder. We copy the
# Doxyfile to the _build folder since it needs to be modified
# to contain the version number.
#
docs-doxygen-cmd:
	# Generating Doxygen docs
	cp $(DOCS_SRC)/doxygen/Doxyfile $(D_BLD)/Doxyfile
	echo "PROJECT_NUMBER = v$(VERSION_TRIPLET)" >> $(D_BLD)/Doxyfile
	$(CNTR_TECH) run --rm -it \
	    --env HOME=/work/$(D_BLD) \
	    --user=$(CNTR_USER) \
	    --volume $$(pwd):/work \
	    --workdir=/work \
	    $(CNTR_DOXYGEN_PATH) doxygen $(D_BLD)/Doxyfile

.PHONY: docs-doxygen-cmd

endif
