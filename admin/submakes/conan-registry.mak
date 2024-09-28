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

include $(D_MAK)/container-tech.mak

# ------------ Registry Template ------------

define CONAN_REGISTRY_TMPLT
# $1 = Conan registry
login-$(1):
	@$$(D_SCP)/conan-registry-login.bash \
	    $$(CNTR_TECH) $(1) $$(CNTR_GCC_TOOLS_NAME)

logout-$(1):
	@$$(D_SCP)/conan-registry-logout.bash \
	    $$(CNTR_TECH) $(1) $$(CNTR_GCC_TOOLS_NAME)

login-status-$(1):
	@$$(D_SCP)/conan-registry-status.bash \
	    $$(CNTR_TECH) $(1) $$(CNTR_GCC_TOOLS_NAME)

.PHONY: login-$(1) logout-$(1) login-status-$(1)

HELP_TXT += "\n\
login-$(1),        Login to $(1) registry\n\
logout-$(1),       Logout from $(1) registry\n\
login-status-$(1), Show login status to $(1) registry\n\
"
endef

# ------------- Render Templates ------------

$(eval $(call CONAN_REGISTRY_TMPLT,conancenter))
$(eval $(call CONAN_REGISTRY_TMPLT,aws-arty))

# There can be several Conan registries. Of these registries we
# need to identity the one to use for publishing our own packages.
# This registry requires a login when publishing. Other registries
# may be readable without a login.
#
CONAN_REGISTRY_FOR_PUBLISHING := conancenter

conan-login-check: login-conancenter

.PHONY: conan-login-check


endif
