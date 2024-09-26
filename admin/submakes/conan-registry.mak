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

_CONAN_REGY_CONANCENTER := conancenter
_CONAN_SRVR_CONANCENTER := https://center.conan.io
_CONAN_REGY_ARTIFACTORY := aws-arty
_CONAN_SRVR_ARTIFACTORY := https://aws.artifactory.io

include $(D_MAK)/container-tech.mak

# ------------ Registry Template ------------

define CONAN_REGISTRY_TMPLT
# $1 = Conan registry
login-$(1):
	@$$(D_SCP)/conan-registry-login.bash $$(CNTR_TECH) $(1)
        
#	$(CPP_BLD_CNTR_EXEC) conan remote set-user \
#	    $(_ARG_CONAN_REGISTRY) kingsolomon
#	$(CPP_BLD_CNTR_EXEC) conan remote auth $(_ARG_CONAN_REGISTRY)

logout-$(1):
	@$$(D_SCP)/conan-registry-logout.bash \
            $$(CNTR_TECH) $(1) $(CNTR_GCC_TOOLS_NAME)

login-status-$(1):
	@$$(D_SCP)/conan-registry-status.bash $$(CNTR_TECH) $(1)
        
#	$(D_SCP)/conan-login-status.bash 
#	@if $(CPP_BLD_CNTR_EXEC) conan remote list-users | \
#	        sed -n "/$(_ARG_CONAN_REGISTRY)/,/authenticated:/p" | \
#	        grep -i true; then \
#	    echo "($(_ARG_CONAN_REGISTRY)) Already logged in"; \
#	else \
#	    echo "($(_ARG_CONAN_REGISTRY)) Not logged in"; \
#	fi

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

endif
