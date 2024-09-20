#!/bin/bash
#
# Fix up AsyncAPI generated message stubs.
#
# As generated with the quicktype template, when multiple message stubs
# are included in the same compilation unit it causes duplicate
# definition compilation errors. Two changes:
# 1. The compilation fix here is to change the 'quicktype' namespace 
#    into distinct namespaces per file. Files named 'AbCdV1.cpp'
#    now have namespace NsAbCdV1
# 2. *.cpp files are renamed to *.h since these are included as headers
# 
# "quicktype" -> NsCommandLogEventV1
#
# Request and Reply messages have some common fields which are defined
# as classes and enum classes by the auto generation tool. The content
# of these common fields is based on service level information and not
# tied to the location in the application where the messages are
# initiated. The design decision was to have the common fields be
# populated in a utility library function. However, because every
# message in its own namespace now (see previous paragraph), the
# common classes cannot be constructed independent of the messages they
# are in. To overcome this limitation, the generated source files are
# further modified in a 2-step process.
# 
# 1. Generate a new header file which contains the common
# classes and enum classes and the corresponding to and from JSON
# functions in a unique namespace. For this step, the AckNakReplyV1
# message is selected, and the non-common parts are extracted.
# The non-common parts include the message and the data classes
# (definition and implementation), and the corresponding to and
# from JSON functions.
#
#   AckNakReplyV1.h -> RequestReplyCommonV1.h
# 
# 2. Remove the definitions of the common classes from all other
# auto generated source files and modify any references to them to
# use the new common namespace.
#
#  Assumed convention: message name contains message type.
# ----------------------------------------------------------------

# Supply path to the directory of generated cpp files.
STUB_DIR=$1

CMN='RequestReplyCommonV1'
INC='#include "'$CMN'.h"'
NSS='<Ns'$CMN'::Security>'
NST='<Ns'$CMN'::Type>'

# Helper function to find and remove a block of code which may be the 
# definition or implementation of a function. Definition contains no {}.
# Implementation may contain nested {}.
removeBlock()
{
    # Input args: search pattern, source file, destination file.
    awk -v p=$1 'BEGIN { found=0; c=0;}
        $0 ~ p { found=1; 
            for (i=1; i<=NF; i++)
            {
                if ($i=="{") c=1;
            }
            next;
        }
        { if (found) {
            for (i=1; i<=NF; i++)
            {
                if ($i=="{") c++;
                if ($i=="}") c--;
            }
            if (c<=0) found = 0;
            next;}
        }
        { if (!found) print;}' $2 > $3
}

# Create a header file based on the common parts of the Request and
# Reply messages in a specific namespace.
generateCommonFile()
{
    cnt=1
    # Remove definition and references to Data.
    awk '/class Data/, /\}\;/ {next} {print}' $STUB_DIR/AckNakReplyV1.cpp \
        > tmp$cnt
    removeBlock "quicktype::Data" tmp$cnt tmp$((++cnt))

    # Remove definition and references to AckNakReplyV1.
    awk '/class AckNakReplyV1/, /\}\;/ {next} {print}' tmp$cnt > \
        tmp$((++cnt)) && let cnt++
    removeBlock "quicktype::AckNakReplyV1" tmp$cnt tmp$((++cnt))

    # Remove/clean up comments.
    awk '/Then include this/, /AckNakReplyV1 data/ {next} {print}' tmp$cnt > \
        tmp$((++cnt)) && let cnt++
    awk '/\/\*\*/, /\*\// {next} {print}' tmp$cnt > tmp$((++cnt)) && let cnt++

    # Remove extra empty lines.
    sed '/^$/N;/^\n$/D' tmp$cnt > $STUB_DIR/$CMN.cpp
}

# Remove the common parts of the Request and Reply messages from all
# Request and Reply message and instead include the file generated in
# generateCommonFile(). Also, modify the namespace of the common parts
# used in the file.
removeCommonParts()
{
    if [[ $1 == *"$CMN"* ]]; then
        return
    fi
    cnt=1
    # Remove classes and enum classes.
    awk '/class Oauth2/, /};/ {next} {print}' $1 > tmp$cnt
    awk '/class Security/, /};/ {next} {print}' tmp$cnt > \
        tmp$((++cnt)) && let cnt++
    awk '/enum class Flow/, /};/ {next} {print}' tmp$cnt > \
        tmp$((++cnt)) && let cnt++
    awk '/enum class Type/, /};/ {next} {print}' tmp$cnt > \
        tmp$((++cnt)) && let cnt++

    # Remove definitions & implementations, to_json and from_json.
    removeBlock "_json.*::Oauth2"   tmp$cnt tmp$((++cnt))
    removeBlock "_json.*::Security" tmp$cnt tmp$((++cnt))
    removeBlock "_json.*::Flow"     tmp$cnt tmp$((++cnt))
    removeBlock "_json.*::Type"     tmp$cnt tmp$((++cnt))

    # Use Security and Type from the new common file.
    awk -v ns=$NSS 'gsub("<.*Security>", ns)1' tmp$cnt > \
        tmp$((++cnt)) && let cnt++
    awk -v ns=$NST 'gsub("<.*Type>", ns)1' tmp$cnt > \
        tmp$((++cnt)) && let cnt++

    # Insert include for the new common file.
    awk -v l="$INC" '/<regex>/ {print;print l;next}1' tmp$cnt > \
        tmp$((++cnt)) && let cnt++

    # Remove all comments.
    awk '/\/\*\*/, /\*\// {next} {print}' tmp$cnt > \
        tmp$((++cnt)) && let cnt++

    # Remove extra empty lines.
    sed '/^$/N;/^\n$/D' tmp$cnt > $1
}

runSedCmd()
{
    # Remove common parts of Request and Reply messages
    if [[ $1 == *"Request"* ]] || [[ $1 == *"Reply"* ]]; then
        removeCommonParts $1
    fi
    base="${1##*/}"            # strip leading path
    namespace="Ns${base%.*}"   # strip .cpp suffix and add Ns
    sed -i.org "s/quicktype/${namespace}/g" $1
}

# Generate a file with common parts of all Request/Reply messages.
generateCommonFile

for f in ${STUB_DIR}/*.cpp ; do
    runSedCmd $f
    mv $f ${f%.*}.h
done
rm tmp* 2> /dev/null
