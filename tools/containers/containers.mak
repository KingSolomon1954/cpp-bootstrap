# -----------------------------------------------------------------
#
# Submake to build, pull and push containers
#
# -----------------------------------------------------------------

ifndef _INCLUDE_CONTAINERS_MAK
_INCLUDE_CONTAINERS_MAK := 1

ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_CNTRS
    $(error Parent makefile must define 'D_CNTRS')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-gcc14.mak
include $(D_MAK)/container-names-gcc11.mak
include $(D_MAK)/container-names-sphinx.mak
include $(D_MAK)/container-registry.mak

_D_CNTR_FILES := $(D_CNTRS)/spec-files

cntr-build-gcc14-tools:
	# Building gcc14 tools container
	$(CNTR_TECH) build -t $(CNTR_GCC_14_TOOLS_PATH) \
	    -f $(_D_CNTR_FILES)/dockerfile-gcc14-tools .

cntr-push-gcc14-tools: login-$(CNTR_GCC_14_TOOLS_REPO)
	# Pushing gcc14 tools container
	$(CNTR_TECH) push $(CNTR_GCC_14_TOOLS_PATH)

cntr-pull-gcc14-tools: login-$(CNTR_GCC_14_TOOLS_REPO)
	# Pulling gcc14 tools container
	$(CNTR_TECH) pull $(CNTR_GCC_14_TOOLS_PATH)

cntr-build-gcc11-tools:
	# Building gcc11 tools container
	$(CNTR_TECH) build -t $(CNTR_GCC_11_TOOLS_PATH) \
	    -f $(_D_CNTR_FILES)/dockerfile-gcc11-tools .

cntr-push-gcc11-tools: login-$(CNTR_GCC_11_TOOLS_REPO)
	# Pushing gcc11 tools container
	$(CNTR_TECH) push $(CNTR_GCC_11_TOOLS_PATH)

cntr-pull-gcc11-tools: login-$(CNTR_GCC_11_TOOLS_REPO)
	# Pulling gcc11 tools container
	$(CNTR_TECH) pull $(CNTR_GCC_11_TOOLS_PATH)

cntr-build-sphinx-tools:
	# Building Sphinx tools container
	$(CNTR_TECH) build -t $(CNTR_SPHINX_TOOLS_PATH) \
	    -f $(_D_CNTR_FILES)/dockerfile-sphinx .

cntr-push-sphinx-tools: login-$(CNTR_SPHINX_TOOLS_REPO)
	# Pushing Sphinx tools container
	$(CNTR_TECH) push $(CNTR_SPHINX_TOOLS_PATH)

cntr-pull-sphinx-tools: login-$(CNTR_SPHINX_TOOLS_REPO)
	# Pulling Sphinx tools container
	$(CNTR_TECH) pull $(CNTR_SPHINX_TOOLS_PATH)

# ------------ Help Section ------------

HELP_TXT += "\n\
cntr-build-gcc14-tools,  Creates $(CNTR_GCC_14_TOOLS_NAME) image\n\
cntr-push-gcc14-tools,   Pushes  $(CNTR_GCC_14_TOOLS_NAME) to $(CNTR_GCC_14_TOOLS_REPO)\n\
cntr-pull-gcc14-tools,   Pulls   $(CNTR_GCC_14_TOOLS_NAME) from $(CNTR_GCC_14_TOOLS_REPO)\n\
cntr-build-gcc11-tools,  Creates $(CNTR_GCC_11_TOOLS_NAME) image\n\
cntr-push-gcc11-tools,   Pushes  $(CNTR_GCC_11_TOOLS_NAME) to $(CNTR_GCC_11_TOOLS_REPO)\n\
cntr-pull-gcc11-tools,   Pulls   $(CNTR_GCC_11_TOOLS_NAME) from $(CNTR_GCC_11_TOOLS_REPO)\n\
cntr-build-sphinx-tools, Creates $(CNTR_SPHINX_TOOLS_NAME) image\n\
cntr-push-sphinx-tools,  Pushes  $(CNTR_SPHINX_TOOLS_NAME) to $(CNTR_SPHINX_TOOLS_REPO)\n\
cntr-pull-sphinx-tools,  Pulls   $(CNTR_SPHINX_TOOLS_NAME) from $(CNTR_SPHINX_TOOLS_REPO)\n\
"

endif
