#!/bin/bash

set -ex

# Source emsdk environment
source ~/repos/emsdk/emsdk_env.sh

./autogen.sh  # Only needed first time
automake

# Configure with Emscripten
emconfigure ./configure \
  --host=wasm32-unknown-emscripten \
  --enable-all-tools=no \
  --with-sfst=no \
  --with-foma=yes \
  --with-openfst=yes \
  --enable-all-tools=no \
  --enable-minimal-tools \
  --disable-load-so-entries \
  --with-readline=no \
  EMSCRIPTEN=1 \
  CXXFLAGS="--use-port=icu -O3" \
  LDFLAGS="--use-port=icu -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap'] -s EXPORTED_FUNCTIONS=['_malloc','_free'] -s ALLOW_MEMORY_GROWTH=1"

# Build wasm dependencies and libhfst
emmake make -C wasm-libs VERBOSE=1
emmake make -C libhfst VERBOSE=1
