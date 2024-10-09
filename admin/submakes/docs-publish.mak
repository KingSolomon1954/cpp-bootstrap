# -----------------------------------------------------------------
#
# Submake to prepare folder for publishing to GitHub Pages
# 
# -----------------------------------------------------------------

ifndef _INCLUDE_DOCS_PUBLISH_MAK
_INCLUDE_DOCS_PUBLISH_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif
ifndef DOCS_OUT
    $(error Parent makefile must define 'DOCS_OUT')
endif

_D_PUB := $(D_DOCS)/site
_D_TMP := $(D_BLD)/tmp

xdocs-publish:
	git rm -r --ignore-unmatch $(_D_PUB)/*
	mkdir -p $(_D_PUB)
	cp -r $(DOCS_OUT)/* $(_D_PUB)/
	touch $(_D_PUB)/.nojekyll
	git add -A $(_D_PUB)
	git commit -m "Website update"
	@echo "Reminder: need to git push when ready."

# SHELL := /bin/bash
#	if [ $$(( 17 == 1 )) ] ; then \

howie:
	if [ $$(ls _build/site/code-coverage/html | wc -w) -eq 1 -a \
	     $$(ls   docs/site/code-coverage/html | wc -w) -gt 1 ]; then \
	    echo "Need to preserve"; \
	    preserve="true"; \
	else \
	    echo "Not preserving"; \
	fi

nancy:
	if [ $$(ls _build/site/code-coverage/html | wc -w) -gt 1 ] ; then \
	    echo yes; \
	else \
	    echo no; \
	fi

# Publishing docs means copying all the files under _build/site
# to the docs/site folder, where they will be checked-in.
# GitHub is setup to treat the docs/pub folder as a static website.
#
# However, there is one complication. If a developer has not yet run a
# code coverage report, there will be an empty code coverage placeholder
# file. In this case we want to avoid overwritting an existing published
# code coverage report if one exists. This is a normal and expected
# workflow. The developer simply wants to publish docs without being
# forced to run another code coverage report or lose an already
# published report.
#
docs-publish: $(_D_TMP)
	if [ $$(ls _build/site/code-coverage/html | wc -w) -eq 1 -a \
	     $$(ls $(_D_PUB)/code-coverage/html   | wc -w) -gt 1 ]; then \
	    preserve="true"; \
	    # Preserve code-coverage contents \
	    rm -rf $(_D_TMP)/code-coverage; \
	    cp -p -r $(_D_PUB)/code-coverage/ $(_D_TMP)/; \
	fi; \
	git rm -r --ignore-unmatch $(_D_PUB)/*; \
	mkdir -p $(_D_PUB); \
	cp -p -r $(DOCS_OUT)/* $(_D_PUB)/; \
	touch $(_D_PUB)/.nojekyll; \
	if [ -n "$${preserve}" ]; then \
	    # Restore code-coverage folder \
	    # echo "Restoring code-coverage folder"; \
	    rm -rf $(_D_PUB)/code-coverage; \
	    mv $(_D_TMP)/code-coverage/ $(D_PUB)/; \
	fi; \
	git add -A $(_D_PUB); \
	git commit -m "Publish documentation"; \
	echo "Reminder: need to git push when ready."

$(_D_TMP):
	@mkdir -p $@

.PHONY: docs-publish

HELP_TXT += "\n\
docs-publish, Update $(_D_PUB) with $(DOCS_OUT) and checkin to Git\n\
"

endif
