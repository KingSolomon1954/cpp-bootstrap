# -----------------------------------------------------------------
#
# This submake is included by individual component Makefiles.
#
# Prints the value of a makefile variable.
# Super when debugging Makefiles.
#
# Use it like so:
#
#    make print-VARIABLE_NAME
# 
# and it will print to console
# VARIABLE = the_value_of_the_variable
#
# -----------------------------------------------------------------
#
ifndef _INCLUDE_PRINT_DEBUG_MAK
_INCLUDE_PRINT_DEBUG_MAK := 1

print-%  : ; @echo $* = $($*)

HELP_TXT += "\n\
print-xxx, Print value of makefile variable xxx\n\
"

endif
