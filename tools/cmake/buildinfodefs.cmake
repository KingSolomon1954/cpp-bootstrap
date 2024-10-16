# Generate the C++ include header "BuildInfoDefs.h" 
#
# This cmake include file generates the C++ include header
# "BuildInfoDefs.h" for directly compiling into the application its
# build version and build dates.
#
# The strategy for build dates and versions adheres to the concept of
# "Reproducible builds" as discussed in the following article.
#
# https://reproducible-builds.org/docs/source-date-epoch/
#
# Basically you only bump versions/dates if something changes, such that
# in the future you can perform a new build against the old code and
# then compare it to the old binary and get a match if nothing has
# changed. This has even more value considering security concerns.
#
# From the article: To set SOURCE_DATE_EPOCH to the last modification of
# a git repository you can use ‘git log’, for example in shell:
# 
# SOURCE_DATE_EPOCH=$(git log -1 --pretty=%ct)
#
# In cmake, setting the SOURCE_DATE_EPOCH within cmake does
# nothing, it needs to come in from the environment in order
# for cmake to recognize it. 
#
# But, rather than have a multi-tiered handoff between shell and cmake
# which would always have to calculate and then supply SOURCE_DATE_EPOCH
# as command line argument, it is simple enough to determine within
# cmake our own SOURCE_DATE_EPOCH. This also avoids concerns over
# having to keep a CI environment in tune with developer environment. We
# use our own variable "BLD_EPOCH" for the same purpose.

# In this section we gather up and set the variables we want 
# to feed to the application as build information.

if (NOT PROJECT_TOP)
    message(FATAL_ERROR "PROJECT_TOP not found. Aborting...")
endif()

if (EXISTS ${PROJECT_TOP}/.git)
    # Get timestamp from last commit log entry.
    execute_process(COMMAND
        git log -1 --pretty=%ct         #  unix time stamp
        OUTPUT_VARIABLE BLD_EPOCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(COMMAND
        git log -1 --pretty=%cI         #  in ISO 8601 format
        OUTPUT_VARIABLE BLD_DATETIME
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(COMMAND
        git branch --show-current
        OUTPUT_VARIABLE BLD_BRANCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    execute_process(COMMAND
        git rev-parse --short=16 HEAD
        OUTPUT_VARIABLE BLD_COMMIT_HASH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
else()
    # Not in git tree, use current date/time.
    # message(STATUS ".git folder not found, using UTC timestamp")
    STRING(TIMESTAMP BLD_EPOCH "%s" UTC)
    STRING(TIMESTAMP BLD_DATETIME UTC)
    set(BLD_BRANCH       "no branch (not in a repo)")
    set(BLD_COMMIT_HASH  "no hash (not in a repo)")
endif()

# Build creator whether in git tree or not
if (DEFINED ENV{GITHUB_ACTOR})
    set(BLD_CREATOR $ENV{GITHUB_ACTOR})
elseif (DEFINED ENV{LOGNAME})
    set(BLD_CREATOR $ENV{LOGNAME})
else()
    # We're on build container so this will always
    # come back as root. Need to explore if this
    # can be improved somehow.
    execute_process(COMMAND
        whoami
        OUTPUT_VARIABLE BLD_CREATOR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

# The rest of this is an optimization to only incur a recompilation when
# the build date truly changes, and therefore generate a new
# BuildInfoDefs.h. Naieve solutions always trigger a recompilation upon
# any invocation of make regardless of whether anything changes. This
#
# Before arriving at the following logic, several solutions were
# attempted using cmake's add_custom_command() and
# add_custom_target(). There was always something in cmake that got it
# wrong. Gave up and wrote this logic.
#
# Makes use of a sentinel header file. A new sentinel is created each
# build and then compared to the existing header file. If these are
# different (via a hash compare) then a new header is written. This
# avoids the unconditional creation of the header each time with a fresh
# timestamp that always incurs a recompilation.

set(bldDefsBase     "BuildInfoDefs.h")
set(bldDefsFileName ${CMAKE_CURRENT_BINARY_DIR}/include/${bldDefsBase})
set(bldDefsSentinel ${CMAKE_CURRENT_BINARY_DIR}/include/${bldDefsBase}.sentinel)
find_file(bldDefsIn ${bldDefsBase}.in PATHS ${CMAKE_MODULE_PATH})
set(needBldDefs false)

# Unconditionally create the sentinel file.
configure_file(${bldDefsIn} ${bldDefsSentinel})

if (EXISTS ${bldDefsFileName})
    file(MD5 ${bldDefsFileName} fileHashA)
    file(MD5 ${bldDefsSentinel} fileHashB)
    if (NOT ${fileHashA} EQUAL ${fileHashB})
        # message(STATUS "Files not equal detected, setting flag")
        set(needBldDefs true)
    endif()
else()
    set(needBldDefs true)
endif()

if (${needBldDefs})
    # message(STATUS "Creating new builddefs header")
    # Can't believe cmake doesn't have a file copy within same folder.
    file(COPY ${bldDefsSentinel} DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/..)
    file(RENAME ${CMAKE_CURRENT_BINARY_DIR}/../${bldDefsBase}.sentinel ${bldDefsFileName})
endif()

unset(needBldDefs)
unset(bldDefsBase)
unset(bldDefsFileName)
unset(bldDefsSentinel)
unset(bldDefsIn)
unset(fileHashA)
unset(fileHashB)
