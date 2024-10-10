# -----------------------------------------------------------------
#
# This submake provides standard variables for PlantUML container.
# 
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_PLANTUML_NAMES_MAK
_INCLUDE_CONTAINER_PLANTUML_NAMES_MAK := 1

CNTR_PLANTUML_IMAGE ?= think/plantuml
CNTR_PLANTUML_VER   ?= latest
CNTR_PLANTUML_REPO  ?= docker.io
CNTR_PLANTUML_PATH  ?= $(CNTR_PLANTUML_REPO)/$(CNTR_PLANTUML_IMAGE):$(CNTR_PLANTUML_VER)
CNTR_PLANTUML_NAME  := plantuml

endif
