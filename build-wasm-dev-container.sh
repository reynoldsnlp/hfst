#!/bin/bash


# This script builds the HFST library for WebAssembly using Emscripten.
# It is intended to be run in a fresh Ubuntu container.

set -ex

if ! [ -d libhfst ]; then
    echo "Please run this script in the HFST root directory."
    exit 1
fi

HFST_DIR="$(pwd)"
DEPS_DIR="${HFST_DIR}/wasm-deps"
INCLUDE_DIR="${DEPS_DIR}/include"
LIB_DIR="${DEPS_DIR}/lib"
mkdir -p ${INCLUDE_DIR}
mkdir -p ${LIB_DIR}

APT_UPDATE_STAMP="/tmp/apt-update-stamp"
if [ ! -f ${APT_UPDATE_STAMP} ]; then
    sudo apt-get update
    touch ${APT_UPDATE_STAMP}
else
    echo "apt-get update already done. Skipping..."
fi
sudo apt-get install -y \
    autoconf \
    automake \
    bison \
    build-essential \
    cmake \
    curl \
    flex \
    git \
    libtool \
    pkg-config \
    python3 \
    python3-jsonschema \
    unzip \
    zlib1g-dev

if ! [ -d emsdk ]; then
    git clone https://github.com/emscripten-core/emsdk.git
fi
if [ -z $(which emcc) ]; then
    pushd emsdk
    ./emsdk install latest
    ./emsdk activate latest
    . emsdk_env.sh
    popd
fi

echo '
=======================================================================
====================== Building Foma ==================================
======================================================================='
cd ${DEPS_DIR}
if [ -f "${LIB_DIR}/libfoma.a" ]; then
  echo "Foma already built (wasm-deps/libfoma.a exists), skipping..."
else
  echo "Building Foma..."
  [ -d foma ] || git clone https://github.com/mhulden/foma.git
  cd foma/foma
  git pull
  emcmake cmake .
  emmake make # -j$(nproc)
  cp libfoma.a ${LIB_DIR}/
fi


echo '
=======================================================================
====================== Building OpenFST ===============================
======================================================================='
cd ${DEPS_DIR}
if [ -f "${LIB_DIR}/libfst.a" ]; then
  echo "OpenFst already built (wasm-deps/libfst.a exists), skipping..."
else
  echo "Building OpenFst..."
  [ -d openfst ] || git clone https://github.com/TinoDidriksen/openfst.git
  cd openfst
  autoreconf -fiv
  emconfigure ./configure --enable-static --disable-shared
  emmake make # -j$(nproc)
  cp src/lib/.libs/libfst.a ${LIB_DIR}/
  [ -d ${DEPS_DIR}/include/fst ] || ln -s ${DEPS_DIR}/openfst/src/include/fst ${DEPS_DIR}/include/
fi

echo '
=======================================================================
====================== Building ICU ===================================
======================================================================='
cd ${DEPS_DIR}
# ICU_SRC_URL="https://github.com/unicode-org/icu/releases/download/release-77-1/icu4c-77_1-src.tgz"
ICU_SRC_URL=$(curl -s https://api.github.com/repos/unicode-org/icu/releases/latest | grep '/icu4c-.*-src.tgz"' | cut -d '"' -f 4)
ICU_SRC_TGZ=$(basename ${ICU_SRC_URL})
ICU_DATA_URL=${ICU_SRC_URL/-src.tgz/-data.zip}
ICU_DATA_ZIP=$(basename ${ICU_DATA_URL})

if ! [ -d icu ]; then
    curl -L -o "${ICU_SRC_TGZ}" "${ICU_SRC_URL}"
    tar -xvf "${ICU_SRC_TGZ}"
    # Hide dat file to force make to rebuild data using filter
    ORIG_DAT="$(pwd)/icu/source/data/in/icudt??l.dat"
    if [ -f ${ORIG_DAT} ]; then
        mv ${ORIG_DAT} ${ORIG_DAT}.hidden
    fi
    # Let config assume that emscripten build is Linux
    cp icu/source/config/mh-linux icu/source/config/mh-unknown
fi

if ! [ -f icu/source/data/locales/root.txt ]; then
    curl -L -o "${ICU_DATA_ZIP}" "${ICU_DATA_URL}"
    mv icu/source/data icu/source/data_from_src_tgz
    unzip "${ICU_DATA_ZIP}" -d icu/source/
fi

export ICU_DATA_FILTER_FILE="$(pwd)/data-filter.json"
echo '{
  "strategy": "additive",

  "localeFilter": {
    "filterType": "language",
    "includelist": ["en"]
  },

  "featureFilters": {
    "brkitr_rules":        "include",
    "brkitr_tree":         "include",

    "cnvalias":            "include",
    "ulayout":             "include",
    "uemoji":              "include",

    "brkitr_dictionaries": "include",
    "brkitr_lstm":         "include",
    "brkitr_adaboost":     "include"
  }
}' > ${ICU_DATA_FILTER_FILE}

pushd icu/source

# Build ICU natively (host build) to generate required tools and ICU data
echo '=================== Building ICU (native tools) ======================='
mkdir -p native-build
pushd native-build
NATIVE_ICU_DIR=$(pwd)
if [ -f "bin/pkgdata" ]; then
  echo "ICU native tools already built (native-build/bin/pkgdata exists), skipping..."
else
  ../configure --disable-shared --enable-static VERBOSE=1
  make -j$(nproc) VERBOSE=1
fi
popd

echo '====================== Building ICU (wasm) ==========================='
mkdir -p wasm-build
pushd wasm-build
if [ -f "lib/libicudata.a" ]; then
  echo "ICU wasm libs already built (wasm-build/lib/libicudata.a exists), skipping..."
else
  export PKGDATA_OPTS="--without-assembly -O ../data/icupkg.inc"
  PKG_CONFIG_LIBDIR="${LIB_DIR}/pkgconfig" emconfigure ../configure \
      --host=wasm32-unknown-emscripten \
      --prefix="${DEPS_DIR}" \
      --with-cross-build="${NATIVE_ICU_DIR}" \
      --enable-static=yes \
      --disable-shared \
      --with-data-packaging=static \
      --enable-icu-config \
      --disable-extras \
      --disable-samples \
      --disable-tests \
      VERBOSE=1

  emmake make -j$(nproc) install
  popd
  popd
echo "WebAssembly ICU build complete. Static libraries are in ${LIB_DIR}"
fi


echo '
=======================================================================
====================== Building LibHFST ===============================
======================================================================='
cd ${HFST_DIR}

if [ ! -f configure ]; then
    ./autogen.sh
fi

emconfigure ./configure \
  --host=wasm32-unknown-emscripten \
  --with-sfst=no \
  --with-foma=yes \
  --with-openfst=yes \
  --enable-no-tools \
  --disable-load-so-entries \
  --with-readline=no \
  CPPFLAGS="-I${DEPS_DIR}/include -I${DEPS_DIR}/foma/foma" \
  FOMA_CFLAGS="-I${DEPS_DIR}/foma/foma" \
  FOMA_LIBS="-L${LIB_DIR} -lfoma" \
  LDFLAGS="-L${LIB_DIR}" \
  VERBOSE=1
# TODO: optimization with -O3 or -O4

echo "Build libhfst"
emmake make -C libhfst VERBOSE=1 -j$(nproc)

echo '
=======================================================================
==================== LibHFST WASM build complete ======================
======================================================================='
