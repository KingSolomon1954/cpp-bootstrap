# -----------------------------------------------------------------
#
# Submake to create a release tarball
# 
# -----------------------------------------------------------------

ifndef _INCLUDE_RELEASE_TARBALL_MAK
_INCLUDE_RELEASE_TARBALL_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif

release-major: BUMP := major
release-major: release

release-minor: BUMP := minor
release-minor: release

release-patch: BUMP := patch
release-patch: release

# Runs all the release targets similar to the Release workflow, but here
# nothing is actually checked-in or tagged. This allows for developing,
# debugging and confirming release targets and artifacts.

release: bump-version \
	 update-changelog \
	 docs \
	 docs-publish \
	 create-tarball \
	 test-tarball

bump-version:
	@git checkout version   # Always start fresh, allow back-to-back runs
	@echo "Bumping \"$(BUMP)\" version"
	@echo "Old version: $$(cat version)"
	@$(D_SCP)/bump-version.bash $(BUMP) version
	@echo "New version: $$(cat version)"

update-changelog:
	@echo "Updating changelog"
	@$(D_SCP)/update-changelog.bash > etc/changelog.md

_D_REL:=$(D_BLD)/release

create-tarball:
	APP_VERSION=$$(cat version); \
	APP_NAME_AND_VERSION="$(APP_NAME)-$${APP_VERSION}" ; \
	TAR_FILE=$(_D_REL)/$${APP_NAME_AND_VERSION}.tgz; \
	TAR_TOP=$(_D_REL)/tarball-staging/$${APP_NAME_AND_VERSION}; \
	mkdir -p $${TAR_TOP}; \
	cp -p version $${TAR_TOP}/; \
	cp -p etc/changelog.md $${TAR_TOP}/; \
	cp -p _build/debug/bin/$(APP_NAME)  $${TAR_TOP}/$(APP_NAME)-db; \
	cp -p _build/prod/bin/$(APP_NAME)   $${TAR_TOP}/$(APP_NAME); \
	tar -czf $${TAR_FILE} --directory=$${TAR_TOP}/.. .; \
	# Create some handoff info to simplify pipeline runs; \
	echo "$$APP_VERSION"           > $(_D_REL)/app-version; \
	echo "$$APP_NAME_AND_VERSION"  > $(_D_REL)/app-name; \
	echo "$$TAR_FILE"              > $(_D_REL)/tarfile-name

test-tarball:
	@echo "Testing tarball"
	@$(D_SCP)/test-tarball.bash $(D_BLD) $$(cat $(_D_REL)/tarfile-name)

release-clean:
	rm -rf $(_D_REL)

.PHONY: create-tarball bump-version \
        update-changelog test-tarball \
        release-major release-minor \
        release-patch release-clean

# ------------ Help Section ------------

HELP_TXT += "\n\
create-tarball,   Creates a release tarball\n\
update-changelog, Updates changelog\n\
bump-version,     Update version file\n\
release-major,    Runs makefile targets for a major release\n\
release-minor,    Runs makefile targets for a minor release\n\
release-patch,    Runs makefile targets for a patch release\n\
release-clean,    Deletes release $(_D_REL) artifacts\n\
"

endif
