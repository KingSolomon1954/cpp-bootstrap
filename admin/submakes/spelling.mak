# -------------------------------------------------------
#
# Submake to run a spelling checker against a given file
# or a tree of files. The check can be run in interactive
# or batch mode.
#
# In interactive mode you are prompted to fix spelling errors. 
# Each file under evaluation will be changed in-place. Interactive
# mode, of course, is meant for desktop spell checking. For 
# interactive invocation use suffix <filepath>.ispell.
#
# In batch mode, a list of mispelled/unrecognized words
# are placed in a file in folder _build/spelling.
# It is up to you to make corrections to source files.
# For batch invocation use suffix <filepath>.bspell.
#
# Example invocation:
#
#   > make docs/src/index.ispell
#   > # You are prompted for corrections and file is changed in-place
#
#   > make docs/src/index.bspell
#   > # Find result in:
#   > # _build/spelling/index.bspell
#
# -------------------------------------------------------

ifndef _INCLUDE_SPELLING_MAK
_INCLUDE_SPELLING_MAK := 1

ifndef D_BLD
    $(error Parent makefile must define 'D_BLD')
endif
ifndef D_DOCS
    $(error Parent makefile must define 'D_DOCS')
endif
ifndef D_MAK
    $(error Parent makefile must define 'D_MAK')
endif

include $(D_MAK)/container-tech.mak
include $(D_MAK)/container-names-spelling.mak

_D_SPELLING_OUT  := $(D_BLD)/spelling
_F_SPELLING_LIST := $(D_BLD)/spelling/file-list.txt
_F_SPELLING_DICT := $(D_DOCS)/src/dictionary/dictionary.txt
_F_SPELLING_HELP := $(D_MAK)/help-files/help-spelling

# ------------ Setup Section ------------

$(_F_SPELLING_DICT):
	$(error Missing $@)

$(_D_SPELLING_OUT):
	@mkdir -p $@

$(_F_SPELLING_HELP):
	$(error Missing $@)

$(_F_SPELLING_LIST): $(_D_SPELLING_OUT) _spelling-force
	find $(D_DOCS)/src -name '*.rst' > $@

_spelling-force:

.PHONY: _spelling-force

# ------------ Single File Batch Mode Section ------------

define _SPELLING_RULE_BATCH
%.bspell : %.$(1) $(_F_SPELLING_DICT) $(_D_SPELLING_OUT)
	$$(CNTR_TECH) run --rm \
	    --volume $$(PWD):/workdir \
	    $$(CNTR_SPELLING_PATH) hunspell -l -H \
	    -p $$(_F_SPELLING_DICT) $$^ | tee $$(_D_SPELLING_OUT)/$$(@F)
	@echo Results in: $(_D_SPELLING_OUT)/$$(@F)
endef

$(eval $(call _SPELLING_RULE_BATCH,md))
$(eval $(call _SPELLING_RULE_BATCH,adoc))
$(eval $(call _SPELLING_RULE_BATCH,rst))
$(eval $(call _SPELLING_RULE_BATCH,html))

# ------------ Single File Interactive Mode Section ------------

define _SPELLING_RULE_INTERACTIVE
%.ispell : %.$(1) $(_F_SPELLING_DICT)
	$$(CNTR_TECH) run -it --rm \
	    --volume $$(PWD):/workdir \
	    $$(CNTR_SPELLING_PATH) hunspell -H \
	    -p $$(_F_SPELLING_DICT) $$^
endef

$(eval $(call _SPELLING_RULE_INTERACTIVE,md))
$(eval $(call _SPELLING_RULE_INTERACTIVE,adoc))
$(eval $(call _SPELLING_RULE_INTERACTIVE,rst))
$(eval $(call _SPELLING_RULE_INTERACTIVE,html))

# ------------ All Docs Batch Mode Section ------------

_SPELLING_SITE_FILE := $(_D_SPELLING_OUT)/spelling-results.txt

spelling: $(_F_SPELLING_DICT) $(_F_SPELLING_LIST)
	$(CNTR_TECH) run --rm \
	    --volume $(PWD):/workdir \
	    $(CNTR_SPELLING_PATH) hunspell -l -H \
	    -p $(_F_SPELLING_DICT) \
	    $$(cat $(_F_SPELLING_LIST)) > $(_SPELLING_SITE_FILE)
	@if which sort 1>&2 > /dev/null; then \
	    sort -f -u -o $(_SPELLING_SITE_FILE) $(_SPELLING_SITE_FILE); \
	else \
	    echo "Skipping sort, no sort utility found."; \
	fi
	@echo Results in $(_SPELLING_SITE_FILE)

# Not all laptops have sort. Using an additional shell
# command to test for it, otherwise just skip it. Don't
# actually need to sort the list.

.PHONY: spelling

# ------------ All Docs Interactive Mode Section ------------

spelling-it: $(_F_SPELLING_DICT) $(_F_SPELLING_LIST)
	$(CNTR_TECH) run -it --rm \
	    --volume $(PWD):/workdir \
	    $(CNTR_SPELLING_PATH) hunspell -H \
	    -p $(_F_SPELLING_DICT) \
	    $$(cat $(_F_SPELLING_LIST))

.PHONY: spelling-it

# ------------ Clean Section ------------

spelling-clean:
	rm -rf $(_D_SPELLING_OUT)

clean:: spelling-clean

.PHONY: spelling-clean

# ------------ Help Section ------------

spelling-help: $(_F_SPELLING_HELP)
	@$(_F_SPELLING_HELP) $(D_MAK)

.PHONY: spelling-help

HELP_TXT += "\n\
<filepath>.bspell,  Spell checks given file in batch mode\n\
<filepath>.ispell,  Spell checks given file interactively\n\
spelling,           Spell checks all docs in batch mode\n\
spelling-it,        Spell checks all docs in interactive mode\n\
spelling-help,      Displays help for spelling usage\n\
spelling-clean,     Deletes spelling artifacts\n\
"

endif
