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
ifndef D_TOOLS
    $(error Parent makefile must define 'D_TOOLS)
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
# To populate Conan registries automatically, the logic reads Conan
# registry property files from tools/conan matching the pattern:
# "registry-*.properties". Properties found in these files are then used
# to setup each registry.

# Sentinel file to setup profile just once.
_CONAN_PROFILE_SETUP_DONE := $(D_BLD)/conan-profile-setup-done

$(_CONAN_PROFILE_SETUP_DONE):
	@if ! $(CPP_BLD_CNTR_EXEC) conan profile path default > /dev/null 2>&1; then \
	    echo "(conan) Setting up default profile"; \
	    $(CPP_BLD_CNTR_EXEC) conan profile detect; \
	fi
	@touch $@

# Sentinel file to setup registries just once. Tie in with conan.mak.
CONAN_REGISTRY_SETUP_DONE := $(D_BLD)/conan-registry-setup-done

_CONAN_REGY_PROP_FILES := $(wildcard $(D_TOOLS)/conan/registry-*.properties)

# Delegate to a script to setup Conan registries.
$(CONAN_REGISTRY_SETUP_DONE): $(_CONAN_PROFILE_SETUP_DONE) \
                              $(_CONAN_REGY_PROP_FILES) \
                              $(D_BLD)/conan-registry-vars.mak
	@$(D_SCP)/conan-registry-setup.bash \
	    $(CNTR_TECH) $(CNTR_GCC_TOOLS_NAME) $(_CONAN_REGY_PROP_FILES)
	@touch $@

$(D_BLD)/conan-registry-vars.mak:
	@echo "(conan) Creating Conan registry-vars file"
	@mkdir -p $(D_BLD)
	@r_names=$$(grep 'name: ' $(_CONAN_REGY_PROP_FILES) | awk '{ ORS=" "; print $$2 }' ); \
	echo "CONAN_REGISTRY_NAMES := $${r_names% *}" > $@
	@f=$$(grep 'publish: yes' -l $(_CONAN_REGY_PROP_FILES) | head -1); \
	if [ -n "$${f}" ]; then \
	    p_name=$$(grep 'name:' $${f} | awk '{ print $$2 }'); \
	else \
	    p_name="NoRegistryFoundForPublishing"; \
	fi; \
	echo "CONAN_REGISTRY_FOR_PUBLISHING := $${p_name}" >> $@

ifneq ($(findstring clean,$(MAKECMDGOALS)),clean)
    -include $(D_BLD)/conan-registry-vars.mak
endif

# ------------- Expand Templates ------------

$(foreach reg,$(CONAN_REGISTRY_NAMES),$(eval $(call CONAN_REGISTRY_TMPLT,$(reg))))

# ------------- Force Conan registry rebuild  ------------

conan-registry: conan-rm-sentinel $(CONAN_REGISTRY_SETUP_DONE)

conan-rm-sentinel:
	@rm -f $(CONAN_REGISTRY_SETUP_DONE)

.PHONY: conan-registry conan-rm-sentinel

# ------------- Conan registy show ------------

conan-registry-show:
	@$(CNTR_TECH) exec $(CNTR_GCC_TOOLS_NAME) conan remote list
	@$(CNTR_TECH) exec -t $(CNTR_GCC_TOOLS_NAME) conan remote list-users

.PHONY: conan-registry-show

# ------------ Help Section ------------

HELP_TXT += "\n\
conan-registry,      Manually trigger Conan registry setup\n\
conan-registry-show, Show Conan registries and users\n\
"

endif
