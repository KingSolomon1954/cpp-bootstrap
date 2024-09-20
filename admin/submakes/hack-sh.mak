# -----------------------------------------------------------------
#
# Symlink /bin/sh to /usr/bin/sh
#
# Unconditionally create a symlink /bin/sh pointing to /usr/bin/sh.
# Debian/Ubuntu no longer populates /bin. CMake unfortunately
# hards codes into Makefiles "SHELL = /bin/sh" and there
# is no way to tell CMake to change it. Tried setting the
# symlink in the Dockerfile but that doesn't work either.
#
# -----------------------------------------------------------------

ifndef _INCLUDE_HACK_SH_MAK
_INCLUDE_HACK_SH_MAK := 1

ifndef CNTR_TECH
    $(error Parent makefile must define 'CNTR_TECH')
endif
ifndef MAK_SHARED
    $(error Parent makefile must define 'MAK_SHARED')
endif

include $(MAK_SHARED)/container-names-gcc.mak

hack-sh:
	$(CNTR_TECH) exec $(CNTR_GCC_TOOLS_NAME) bash -c \
	    "if [ ! -f /bin/sh ]; then ln -s /usr/bin/sh /bin/sh; fi"

.PHONY: hack-sh

HELP_TXT += "\n\
hack-sh, Symlink /bin/sh to /usr/bin/sh on bld container\n\
"

endif
