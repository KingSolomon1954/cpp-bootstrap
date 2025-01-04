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
ifndef D_SCP
    $(error Parent makefile must define 'D_SCP')
endif
ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif
ifndef DOCS_OUT
    $(error Parent makefile must define 'DOCS_OUT')
endif

docs-publish:
	@$(D_SCP)/docs-publish.bash $(DOCS_OUT) $(D_DOCS)/site

.PHONY: docs-publish

HELP_TXT += "\n\
docs-publish, Update $(D_DOCS)/site with $(DOCS_OUT)\n\
"

endif
