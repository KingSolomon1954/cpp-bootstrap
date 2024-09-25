# -----------------------------------------------------------------
#
# Submake provides targets for container registry management
#
# These just delegate to a script.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_REGISTRY_LOGIN_MAK
_INCLUDE_REGISTRY_LOGIN_MAK := 1

ifndef D_SCP
    $(error Parent makefile must define 'D_SCP')
endif

_REGISTRY_DOCKER_HUB  := docker.io
_REGISTRY_GITHUB      := ghcr.io
_REGISTRY_ARTIFACTORY := artifactory.io

include $(D_MAK)/container-tech.mak

# ------------ Login Registry Section ------------

login-$(_REGISTRY_DOCKER_HUB):  _ARG_REGISTRY := $(_REGISTRY_DOCKER_HUB)
login-$(_REGISTRY_DOCKER_HUB):  _login-registry
login-$(_REGISTRY_GITHUB):      _ARG_REGISTRY := $(_REGISTRY_GITHUB)
login-$(_REGISTRY_GITHUB):      _login-registry
login-$(_REGISTRY_ARTIFACTORY): _ARG_REGISTRY := $(_REGISTRY_ARTIFACTORY)
login-$(_REGISTRY_ARTIFACTORY): _login-registry

_login-registry:
	@$(D_SCP)/registry-login.bash $(CNTR_TECH) $(_ARG_REGISTRY)

# ------------ Logout Registry Section ------------

logout-$(_REGISTRY_DOCKER_HUB):  _ARG_REGISTRY := $(_REGISTRY_DOCKER_HUB)
logout-$(_REGISTRY_DOCKER_HUB):  _logout-registry
logout-$(_REGISTRY_GITHUB):      _ARG_REGISTRY := $(_REGISTRY_GITHUB)
logout-$(_REGISTRY_GITHUB):      _logout-registry
logout-$(_REGISTRY_ARTIFACTORY): _ARG_REGISTRY := $(_REGISTRY_ARTIFACTORY)
logout-$(_REGISTRY_ARTIFACTORY): _logout-registry

_logout-registry:
	@$(D_SCP)/registry-logout.bash $(CNTR_TECH) $(_ARG_REGISTRY)

# ------------ Login Status Section ------------

login-status-$(_REGISTRY_DOCKER_HUB):  _ARG_REGISTRY := $(_REGISTRY_DOCKER_HUB)
login-status-$(_REGISTRY_DOCKER_HUB):  _login-status-registry
login-status-$(_REGISTRY_GITHUB):      _ARG_REGISTRY := $(_REGISTRY_GITHUB)
login-status-$(_REGISTRY_GITHUB):      _login-status-registry
login-status-$(_REGISTRY_ARTIFACTORY): _ARG_REGISTRY := $(_REGISTRY_ARTIFACTORY)
login-status-$(_REGISTRY_ARTIFACTORY): _login-status-registry

_login-status-registry:
	@$(D_SCP)/registry-status.bash $(CNTR_TECH) $(_ARG_REGISTRY)

.PHONY: login-$(_REGISTRY_DOCKER_HUB) \
        login-$(_REGISTRY_GITHUB) \
        login-$(_REGISTRY_ARTIFACTORY) \
        logout-$(_REGISTRY_DOCKER_HUB) \
        logout-$(_REGISTRY_GITHUB) \
        logout-$(_REGISTRY_ARTIFACTORY) \
        login-status-$(_REGISTRY_DOCKER_HUB) \
        login-status-$(_REGISTRY_GITHUB) \
        login-status-$(_REGISTRY_ARTIFACTORY) \
        _login-registry _logout-registry _login-status-registry

# ------------ Help Section ------------

HELP_TXT += "\n\
login-$(_REGISTRY_DOCKER_HUB),         Login to $(_REGISTRY_DOCKER_HUB) registry\n\
login-$(_REGISTRY_GITHUB),             Login to $(_REGISTRY_GITHUB) registry\n\
login-$(_REGISTRY_ARTIFACTORY),        Login to $(_REGISTRY_ARTIFACTORY) registry\n\
logout-$(_REGISTRY_DOCKER_HUB),        Logout from $(_REGISTRY_DOCKER_HUB) registry\n\
logout-$(_REGISTRY_GITHUB),            Logout from $(_REGISTRY_GITHUB) registry\n\
logout-$(_REGISTRY_ARTIFACTORY),       Logout from $(_REGISTRY_ARTIFACTORY) registry\n\
login-status-$(_REGISTRY_DOCKER_HUB),  Show login status of $(_REGISTRY_DOCKER_HUB) registry\n\
login-status-$(_REGISTRY_GITHUB),      Show login status of $(_REGISTRY_GITHUB) registry\n\
login-status-$(_REGISTRY_ARTIFACTORY), Show login status of $(_REGISTRY_ARTIFACTORY) registry\n\
"

endif
