#!/bin/bash

set -ex

echo "Source emsdk environment"
source ~/repos/emsdk/emsdk_env.sh

# ./autogen.sh  # Only needed first time
autoreconf -fiv

echo "Configure with Emscripten"
emconfigure ./configure \
  --host=wasm32-unknown-emscripten \
  --with-sfst=no \
  --with-foma=yes \
  --with-openfst=yes \
  --enable-no-tools \
  --disable-load-so-entries \
  --with-readline=no \
  VERBOSE=1 \
  EMSCRIPTEN=1 \
  CPPFLAGS="-I$(pwd)/wasm-libs/foma/foma -I$(pwd)/wasm-libs/openfst/src/include" \
  CXXFLAGS="--use-port=icu"
# TODO: optimization with -O3 or -O4

echo "Build dependencies in wasm-libs"
emmake make -C wasm-libs VERBOSE=1
echo "Build libhfst"
emmake make -C libhfst VERBOSE=1
echo "Successfully completed!"
