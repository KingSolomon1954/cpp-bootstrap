# -----------------------------------------------------------------
#
# Submake provides targets for Conan registries
#
# These just delegate to a script.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONAN_REGISTRY_MAK
_INCLUDE_CONAN_REGISTRY_MAK := 1

ifndef D_SCP
    $(error Parent makefile must define 'D_SCP')
endif
ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif
ifndef D_ADMIN
    $(error Parent makefile must define 'D_ADMIN')
endif
ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif

include $(D_MAK)/container-tech.mak

# ------------ Registry Template ------------

define CONAN_REGISTRY_TMPLT
# $1 = Conan registry
login-$(1):
	@$$(D_SCP)/conan-registry-login.bash \
	    $$(CNTR_TECH) $$(CNTR_GCC_TOOLS_NAME) $(1)

logout-$(1):
	@$$(D_SCP)/conan-registry-logout.bash \
	    $$(CNTR_TECH) $$(CNTR_GCC_TOOLS_NAME) $(1)

login-status-$(1):
	@$$(D_SCP)/conan-registry-status.bash \
	    $$(CNTR_TECH) $$(CNTR_GCC_TOOLS_NAME) $(1)

.PHONY: login-$(1) logout-$(1) login-status-$(1)

HELP_TXT += "\n\
login-$(1),        Login to $(1) registry\n\
logout-$(1),       Logout from $(1) registry\n\
login-status-$(1), Show login status to $(1) registry\n\
"
endef

# ------------- Initial Registry Setup ------------
#
# Need to populate registries into Conan just once, at initialization
# time and before any library retrieval is attempted.
#
# A registry can be configured in Conan with or without having Conan
# establish a login to it. If your project is a Conan library consumer,
# then generally you don't need a login. conancenter works this way. But
# some registries require a login even for consumer-only operations.
#
# To populate Conan registries automatically, the logic reads matching
# Conan registry property files from admin/conan using the pattern:
# "registry-*.properties". Properties found in these files are then used
# to setup each registry.

# Sentinel file so we setup registries just once.
CONAN_REGISTRY_SETUP_DONE := $(D_BLD)/.conan-registry-setup-done

# Delegate to a script to setup Conan registries.
$(CONAN_REGISTRY_SETUP_DONE): $(_CONAN_REGISTRIES)
	@$(D_SCP)/conan-registry-setup.bash \
	    $(CNTR_TECH) $(CNTR_GCC_TOOLS_NAME) $(_CONAN_REGISTRIES)
	@touch $@

conan-registry-setup: $(CONAN_REGISTRY_SETUP_DONE)

_CONAN_REGISTRIES := $(wildcard $(D_ADMIN)/conan/registry-*.properties)

# Get the name of each registry from the file name itself. Could instead
# grep each file and lift out the name attribute from within but want to
# avoid unconditional greps every invocation of make.
#
_CONAN_REGY_NAMES := $(notdir $(_CONAN_REGISTRIES))
_CONAN_REGY_NAMES := $(subst registry-,,$(_CONAN_REGY_NAMES))
_CONAN_REGY_NAMES := $(subst .properties,,$(_CONAN_REGY_NAMES))

# ------------- Expand Templates ------------

$(foreach reg,$(_CONAN_REGY_NAMES),$(eval $(call CONAN_REGISTRY_TMPLT,$(reg))))

# ------ Identify Registry for Publishing  ------
#
# Determine which Conan registry is to be used for publishing. The
# result of this logic is to set makefile variable
# "CONAN_REGISTRY_FOR_PUBLISHING", which is used in conan.mak.
#
# Search for registry property files in the admin/conan folder looking
# for the property "publish: yes". If multiple registry files are found
# to contain "publish: yes", only the first one found is used (the head
# -1 command below). It is not an error if no registry is indicated for
# publishing, which is typical for Conan consumer-only projects.
#
$(D_BLD)/conan-publish-registry.mak: $(_CONAN_REGISTRIES) $(D_BLD)
	@f=$$(grep 'publish: yes' -l $(_CONAN_REGISTRIES) | head -1); \
	if [ -n "$${f}" ]; then \
	    name=$$(grep 'name:' $${f} | awk '{ print $$2 }'); \
	else \
	    name="NoRegistryFoundForPublishing"; \
	fi; \
	echo "CONAN_REGISTRY_FOR_PUBLISHING := $${name}" > $@

# The following triggers the above rule early in makefile
# processing if the file is missing.
#
include $(D_BLD)/conan-publish-registry.mak

endif
