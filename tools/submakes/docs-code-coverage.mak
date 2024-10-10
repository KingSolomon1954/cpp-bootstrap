# -------------------------------------------------------
#
# Submake to populate code coverage folder under the docs tree
#
# -------------------------------------------------------

ifndef _INCLUDE_DOCS_CODE_COVERAGE_MAK
_INCLUDE_DOCS_CODE_COVERAGE_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef DOCS_OUT
    $(error Parent makefile must define 'DOCS_OUT')
endif

docs-code-coverage-cmd:
	# Copying code coverage folder if it exists
	@if [ -f $(D_BLD)/debug/coverage/index.html ]; then \
	    rm -rf $(DOCS_OUT)/code-coverage/html/* ; \
	    cp -p -r $(D_BLD)/debug/coverage/* $(DOCS_OUT)/code-coverage/html; \
	fi

.PHONY: docs-code-coverage-cmd

endif
