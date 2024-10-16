# -------------------------------------------------------
#
# Submake to populate static analysis folder under the docs tree
#
# -------------------------------------------------------

ifndef _INCLUDE_DOCS_STATIC_ANALYSIS_MAK
_INCLUDE_DOCS_STATIC_ANALYSIS_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef DOCS_OUT
    $(error Parent makefile must define 'DOCS_OUT')
endif

docs-static-analysis-cmd:
	@echo "Copying static analysis folder if it exists"; \
	if [ -f $(D_BLD)/static-analysis/report/index.html ]; then \
	    rm -rf $(DOCS_OUT)/static-analysis/* ; \
	    cp -p -r $(D_BLD)/static-analysis/* \
                $(DOCS_OUT)/static-analysis ; \
	    echo "Static analysis folder copied"; \
	else \
	    echo "Skipping: folder does not exist: $(D_BLD)/static-analysis/report/index.html"; \
	fi

.PHONY: docs-static-analysis-cmd

endif
