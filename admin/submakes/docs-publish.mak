# -----------------------------------------------------------------
#
# Submake to prepare folder for publishing to GitHub Pages
# 
# -----------------------------------------------------------------

ifndef _INCLUDE_DOCS_PUBLISH_MAK
_INCLUDE_DOCS_PUBLISH_MAK := 1

ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif
ifndef DOCS_OUT
    $(error Parent makefile must define 'DOCS_OUT')
endif

_D_DOCS_PUB := $(D_DOCS)/site

docs-publish:
	git rm -r --ignore-unmatch $(_D_DOCS_PUB)/*
	cp -r $(DOCS_OUT)/* $(_D_DOCS_PUB)/
	touch $(_D_DOCS_PUB)/.nojekyll
	git add -A $(_D_DOCS_PUB)
	git commit -m "Website update"
	@echo "Reminder: need to git push when ready."

.PHONY: docs-publish

HELP_TXT += "\n\
docs-publish, Update $(_D_DOCS_PUB) with $(DOCS_OUT) and checkin to Git\n\
"

endif
