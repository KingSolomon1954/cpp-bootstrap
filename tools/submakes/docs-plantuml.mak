# -------------------------------------------------------
#
# Submake to build PlantUML docs
#
# -------------------------------------------------------

ifndef _INCLUDE_DOCS_PLANTUML_MAK
_INCLUDE_DOCS_PlANTUML_MAK := 1

ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_IMAGES_SRC
    $(error Parent makefile must define 'D_IMAGES_SRC')
endif
ifndef D_IMAGES_PUB
    $(error Parent makefile must define 'D_IMAGES_PUB')
endif
ifndef PNGS
    $(error Parent makefile must define 'PNGS')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-plantuml.mak

docs-png-cmd: $(PNGS)

$(D_IMAGES_PUB)/%.png : %.puml
# Generating $(D_IMAGES_PUB)/$(@F)
	cat $< | $(CNTR_TECH) run --rm -i \
		$(CNTR_PLANTUML_PATH) -tpng > $(D_IMAGES_PUB)/$(@F)

VPATH += $(D_IMAGES_SRC)

.PHONY: docs-png-cmd

endif
