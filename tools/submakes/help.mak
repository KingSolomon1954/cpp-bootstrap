# -----------------------------------------------------------------
#
# This submake supplies the common help target.
#
# Prints out section from Makefile between two sentinels.
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_HELP_MAK
_INCLUDE_HELP_MAK := 1

help:
	@sed -n "/^# *Start Section/,/^# *End Section/p" Makefile | \
	sed -e "/^# Start Section/d" -e "/^# End Section/d" | \
	colrm 1 2
	@echo $(HELP_TXT) | \
	sed '/^[[:space:]]*$$/d' | \
	sed 's/^[[:space:]]*//g' | \
	sort | \
	awk 'BEGIN { FS="," ; longest=0 } \
	    { \
	        count++; \
	        left[count] = $$1; \
	        right[count] = $$2; \
	        sub(/^[ \n\r\t]+/, "", right[count]) ; \
	        if (length(left[count]) > longest) { \
	            longest = length(left[count]) \
	        } \
	    } \
	    END { \
	        for (i = 1; i <= count; i++) \
	        { \
	            printf "%-*s - %s\n", longest, left[i], right[i] \
	        } \
	    } \
	'
.PHONY: help

HELP_TXT += "\n\
help, Displays help information and targets\n\
"

endif
