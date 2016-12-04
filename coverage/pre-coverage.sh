#!/bin/bash

set -e

COVERAGE_TOOLS_DIR=${COVERAGE_TOOLS_DIR:-"$(dirname $0)"}

# patch things up
patch -p1 < "$COVERAGE_TOOLS_DIR/patches.diff"
export PATH="$(pwd):$PATH"

# if we don't have our npm dependencies available, build node and fetch them
# with npm
if [ ! -x "./node_modules/.bin/nyc" ] || \
  [ ! -x "./node_modules/.bin/istanbul-merge" ]; then
 echo "Building, without lib/ coverage..." >&2
 ./configure
 make -j $(getconf _NPROCESSORS_ONLN) node
 ./node -v


 # get nyc + istanbul-merge
 "./node" "./deps/npm" install istanbul-merge@1.1.0
 "./node" "./deps/npm" install nyc@8.0.0-candidate

 test -x "./node_modules/.bin/nyc"
 test -x "./node_modules/.bin/istanbul-merge"
fi


echo "Instrumenting code in lib/..."
"./node_modules/.bin/nyc" instrument lib/ lib_/
sed -e s~"'"lib/~"'"lib_/~g -i~ node.gyp

echo "Removing old coverage files"
rm -rf coverage
rm -rf out/Release/.coverage
rm -f out/Release/obj.target/node/src/*.gcda
