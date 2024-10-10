# -----------------------------------------------------------------
#
# Submake provides targets for container registries
#
# These just delegate to a script.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_CONTAINER_REGISTRY_MAK
_INCLUDE_CONTAINER_REGISTRY_MAK := 1

ifndef D_SCP
    $(error Parent makefile must define 'D_SCP')
endif
ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif

include $(D_MAK)/container-tech.mak

# ------------ Registry Template ------------

define CNTR_REGISTRY_TMPLT
login-$(1):
	@$$(D_SCP)/container-registry-login.bash $$(CNTR_TECH) $(1)

logout-$(1):
	@$$(D_SCP)/container-registry-logout.bash $$(CNTR_TECH) $(1)

login-status-$(1):
	@$$(D_SCP)/container-registry-status.bash $$(CNTR_TECH) $(1)

.PHONY: login-$(1) logout-$(1) login-status-$(1)

HELP_TXT += "\n\
login-$(1),        Login to $(1) registry\n\
logout-$(1),       Logout from $(1) registry\n\
login-status-$(1), Show login status to $(1) registry\n\
"
endef

# ------------- Render Templates ------------

$(eval $(call CNTR_REGISTRY_TMPLT,docker.io))
$(eval $(call CNTR_REGISTRY_TMPLT,ghcr.io))
$(eval $(call CNTR_REGISTRY_TMPLT,artifactory.io))

endif
