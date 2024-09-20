#!/usr/bin/env bash
#
# FILE
#     clean-exit - test executable for clean exit
#
# SYNOPSIS
#     clean-exit [options] executable
#
# OPTIONS
#     [-h | -help] = show invocation options
#     [-s] = stop at first failure
#     [-r <count>] = repeat test this many times
#     [-min <interrupt interval seconds (default = 2)]
#     [-max <interrupt interval seconds (default = 2)]
#     <file> = the executable under test
#
# DESCRIPTION
#     Checks executable for a clean shutdown.
#     Runs the executable (for example, sample-app program), sends it a
#     signal to exit, and then checks the return code for successful
#     exit.  Anything other than a successful exit indicates some kind
#     of faulty shutdown.
#
#     If min and max are the same value then an exit signal is 
#     sent to the executable at fixed intervals.
#     If min and max are different, they form a range of seconds
#     from which a random value is chosen on each iteration to
#     send an exit signal.
#
# EXAMPLE
#      # Sitting in the _build folder:
#      ../etc/scripts-shared/clean-exit.bash bin/sgn-sample-app
# 
# ENVIRONMENT
#     N/A
#
# BUGS
#     N/A
#
# -----------------------------------------------------------

# Global variables. Actually, in a shell script, all variables in all
# functions are global, so be careful. The variables set here are those
# variables which are intended to be accessed globally.
#
cmdName=`basename $0`
repeatCount=1
successCount=0
failureCount=0
stopOnFailure="false"
minInterval=2
maxInterval=2
RANDOM=$(date +%s%N | cut -b10-19)

# Main body of script. 
#
main ()
{
    # set to call exitClean on SIGINT(2) or SIGTERM(15)
    trap 'exitClean 1' 2 15

    # parse arguments
    while [ $# -ne 0 ]; do

        case $1 in
        -h)
            usage
            exitClean 0;;
        -help)
            usage
            exitClean 0;;
        -min)
            if [ $# -lt 2 ]; then
                usage No argument specified along with \"$1\" option.
                exitClean 1
            fi
            minInterval=$2
            shift;;
        -max)
            if [ $# -lt 2 ]; then
                usage No argument specified along with \"$1\" option.
                exitClean 1
            fi
            maxInterval=$2
            shift;;
        -r)
            if [ $# -lt 2 ]; then
                usage No argument specified along with \"$1\" option.
                exitClean 1
            fi
            repeatCount=$2
            shift;;
        -s)
            # example of handling an option which doesn't require an argument
            stopOnFailure="true";;
        -*)
            usage Invalid option \"$1\".
            exitClean 1;;
        *)
            # executable is non-flag argument
            if [ "${files}" = "" ]; then
                files="$1"
            else
                files="${files} $1"
            fi;;
        esac

        shift
    done

    if [ "${files}" = "" ]; then
        usage No files specified.
        exitClean 1
    fi

    loop

    exitClean 0
}

# -----------------------------------------------------------

showLoopBanner()
{
    echo "----------------------------------"
    echo
    echo "Loop: ${count}"
    echo "Successful exits: ${successCount}"
    echo "Failure    exits: ${failureCount}"
    echo
    echo "----------------------------------"
}

# -----------------------------------------------------------

loop()
{
    let count=0
    while ((count < ${repeatCount} )); do
        let count=count+1
        runIt
        showLoopBanner
        if [ ${stopOnFailure} == "true" ]; then
            if (( failureCount > 0 )); then
                break
            fi
        fi
    done    
}

# -----------------------------------------------------------

runIt()
{
    ${files} &
    killIt &
    if wait %?files; then
        let successCount++
    else
        let failureCount++
        kill %killIt
    fi
}

# -----------------------------------------------------------

killIt()
{
    if (( minInterval == maxInterval )); then
        let sleepRandom=minInterval
    else
        let sleepRandom=$(( ${RANDOM} % maxInterval + minInterval ))
    fi

    sleep ${sleepRandom}
    /bin/kill -s SIGTERM $(basename ${files})
}

# -----------------------------------------------------------

# Clean up any resources that were reserved (temporary files, etc), then
# exit with the passed exit status.
#
exitClean ()
{
    # exit with passed exit status (if not specified, default to 1)

    if (( $1 == 1 )) && (( count > 0 )); then
        showLoopBanner
    fi
    
    exit ${1:-1}
}

# -----------------------------------------------------------

# Show the passed message (if a message was specified),
# followed by the usage extracted from the SYNOPSIS and
# OPTIONS sections in the prologue at the top of this
# script.
#
usage ()
{
    # first output any passed message
    if [ $# -ne 0 ]; then stdErr "$*"; fi

    # Extract usage from prologue at top of script and output it. The first
    # "sed" outputs from the first line up to the "# DESCRIPTION" line (to
    # limit how much of the script is parsed, for speed). The second "sed"
    # extracts everything between SYNOPSIS and DESCRIPTION. The third "sed"
    # eliminates the lines which begin with SYNOPSIS, DESCRIPTION, and
    # OPTIONS. The last "sed" strips any '#' off the beginning of each
    # line and eliminates blank lines.
    #
    stdErr "Usage:"
    sed "/^# *DESCRIPTION/q" $0 | \
        sed -n "/^# *SYNOPSIS/,/^# *DESCRIPTION/p" | \
        sed -e "/^# *SYNOPSIS/d" -e "/^# *DESCRIPTION/d" -e "/^# *OPTIONS/d" | \
        sed -e "s/^#//"  -e "/^ *$/d" 1>&2
}

# -----------------------------------------------------------

# Output text to standard out.
#
stdOut ()
{
    echo "$*"
}

# -----------------------------------------------------------

# Output text to standard error.
#
stdErr ()
{
    echo "$*" 1>&2
}

# -----------------------------------------------------------

# Invoke main body of script (never returns). This must appear at the
# bottom of the script, so all functions which main() calls are visible
# to main().
#
if [ $# != 0 ]; then
    main "$@"
else
    main
fi

# -----------------------------------------------------------
