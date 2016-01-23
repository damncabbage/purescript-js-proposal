#!/bin/sh -eux
#
# Simulating some of the things that may encompass a private-JS-dependency process.
#
SCRIPT_DIR=$(dirname "$0")
cd $SCRIPT_DIR # Just in case.

# Install our JS dependencies for the below. The bower_component dependencies have
# been committed to this repo only for the sake of demonstration.
export PATH="node_modules/.bin:${PATH}"
npm install

##
## Roughly shimming the things Pallet might do on install, except
## inside the program itself and not literally a bunch of shelling-out.
##
pushd bower_components
  for LIB in purescript-*; do
    if [ -f "${LIB}/package.json" ]; then
      pushd "${LIB}"
        echo "Installing npm libraries for ${LIB}"
        npm install
      popd
    fi
  done
popd

##
## Shimming a really dumb brute-force way of providing JS FFI dependencies for
## each module on a regular build:
##
rm -rf output  # We're dumping extra stuff into that directory; clear it out just in case.
pulp build --force --require-path=".."
pushd bower_components
  for JSLIB in purescript-*/package.json; do
    PKG=$(dirname "$JSLIB")
    mkdir -p ../output/ffi/${PKG}
    cp -a "${PKG}/node_modules" "../output/ffi/${PKG}"
  done
popd
pushd output/
  # Really, really dumb-looking in this shell-script, but let's say we have a mapping
  # between packaage and individual modules. This is hardcoded here for demonstration only.
  ln -s ../ffi/purescript-foo/node_modules ./Foo/node_modules
  ln -s ../ffi/purescript-bar/node_modules ./Bar/node_modules
  # This would include symlinking to output/Foo.Types/node_modules, output/Bar.Internal.Quux, etc. if there were more modules.
popd

## Test run; should print three lines:
pulp run

##
## Shimming the things needed for a bundled build.
##
# psc-bundle doesn't work out of the box for this right now. I needed to reach for browserify, as it pulled in
# each output/Foo.Thing module node_modules into the generated file; I have no intention of it being any sort
# of permanent dependency.
# Hardcoding Main here for the sake of demonstration. This bundleEntry simulates our main() call at the bottom
# of the psc-bundled output.
cat > output/bundleEntry.js <<EOF
require('./Main').main();
EOF
browserify output/*/*.js -e output/bundleEntry.js -o output/bundle.js

## Bundle test run; should print three lines:
node output/bundle.js

echo "Done."
