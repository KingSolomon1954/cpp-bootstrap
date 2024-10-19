#!/usr/bin/env bash
#
# File: container-registry-logout.bash
#
# ---------------------------------------------------------------------
#
# $1 = Code Coverage Report to process

codeCoverageReport=$1   # Input file: grab lcov coverage percentage
badgeFile=$2            # Output file: yml file with badge params

cat << EOF > ${badgeFile}
badge:
  coverage-percent: placeholder
EOF

value=$(grep -oP -e '(?<=class="headerCovTableEntryLo">).*?(?=%</td>)|(?<=class="headerCovTableEntryMed">).*?(?=%</td>)' ${codeCoverageReport} | head -n 1)
value=${value%% }   # remove trailing spaces
sed -e "s/placeholder/${value}%/g" -i ${badgeFile}

exit 0

# value=$(grep -oP -e '(?<=class="headerCovTableEntryLo">).*?(?=%</td>)|(?<=class="headerCovTableEntryMed">).*?(?=%</td>)' $(_CVG_REPORT) | head -n 1)" > $(_CVG_PERCENT)
# value=$(cat _build/debug/coverage/unit-test-cpp-percentage)

cat << EOF > ${badgeFile}
{
    "schemaVersion": 1,
    "label": "coverage",
    "message": "placeholder",
    "color": "orange"
}
EOF


jsonString()
{
    echo "{"
    echo "    \"schemaVersion\": 1,"
    echo "    \"label\": \"coverage\","
    echo "    \"message\": \"placeholder%\","
    echo "    \"color\": \"orange\""
    echo "}"
}

jsonString2()
{
while read line; do
    echo $line
done << EOF 
{
    "schemaVersion": 1,
    "label": "coverage",
    "message": "placeholder%",
    "color": "orange"
}
EOF
}

# var=$(jsonString2)

# printf -v xyz "{\n    \"schema\": 1,\n} "
# printf "{\n    \"schema\": 1,\n} "
# echo ${xyz}

echo ${var}

# echo "{ "; \
# echo "    \"schemaVersion\": 1,"; \
# echo "    \"label\": \"coverage\","; \
# echo "    \"message\": \"placeholder\","; \
# echo "    \"color\": \"orange\""; \
# echo "}"

