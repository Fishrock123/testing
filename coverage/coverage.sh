#!/bin/bash

set -e

COVERAGE_TOOLS_DIR=${COVERAGE_TOOLS_DIR:-"$(pwd)/$(dirname $0)"}
WORKSPACE=${WORKSPACE:-"$(pwd)"}
HOME=${HOME:-"$(pwd)"}

export PATH="$(pwd):$PATH"
echo "Gathering coverage..." >&2

mkdir -p coverage .cov_tmp
"$WORKSPACE/node_modules/.bin/istanbul-merge" --out .cov_tmp/libcov.json \
 'out/Release/.coverage/coverage-*.json'
(cd lib && "$WORKSPACE/node_modules/.bin/nyc" report \
 --temp-directory "$(pwd)/../.cov_tmp" -r html --report-dir "../coverage")
# (cd out && "$WORKSPACE/gcovr/scripts/gcovr" --gcov-exclude='.*deps' --gcov-exclude='.*usr' -v \
#  -r Release/obj.target/node --html --html-detail \
#  -o ../coverage/cxxcoverage.html)

mkdir -p "$HOME/coverage-out"
OUTDIR="$HOME/coverage-out/out"
COMMIT_ID=$(git rev-parse --short=16 HEAD)

mkdir -p "$OUTDIR"
cp -rv coverage "$OUTDIR/coverage-$COMMIT_ID"

# JSCOVERAGE=$(grep -B1 Lines coverage/index.html | \
#  head -n1 | grep -o '[0-9\.]*')
# CXXCOVERAGE=$(grep -A3 Lines coverage/cxxcoverage.html | \
#  grep style | grep -o '[0-9]\{1,3\}\.[0-9]\{1,2\}')

# echo "JS Coverage: $JSCOVERAGE %"
# echo "C++ Coverage: $CXXCOVERAGE %"

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "$NOW,$COMMIT_ID" >> "$OUTDIR/index.csv"
cd $OUTDIR/..
$COVERAGE_TOOLS_DIR/generate-index-html.py
