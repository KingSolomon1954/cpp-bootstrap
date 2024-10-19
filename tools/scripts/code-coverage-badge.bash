#!/usr/bin/env bash
#
# File: container-registry-logout.bash
#
# ---------------------------------------------------------------------
#
# $1 = Input file: lcov coverage report
# $2 = Output file: create yml file with badge params

codeCoverageReport=$1
badgeFile=$2

# Format yaml file
cat << EOF > ${badgeFile}
badge:
  coverage-percent: placeholder
EOF

# Grab percentage from lcov coverage report
value=$(grep -oP -e '(?<=class="headerCovTableEntryLo">).*?(?=%</td>)|(?<=class="headerCovTableEntryMed">).*?(?=%</td>)' ${codeCoverageReport} | head -n 1)
value=${value%% }   # trim trailing spaces

# Put value in the yaml file
sed -e "s/placeholder/${value}/g" -i ${badgeFile}
