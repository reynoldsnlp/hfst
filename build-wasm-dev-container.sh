#!/bin/bash


# This script builds the HFST library for WebAssembly using Emscripten.
# It is intended to be run in a fresh Ubuntu container.

set -ex

HFST_DIR="$(pwd)"
DEPS_DIR="${HFST_DIR}/wasm-deps"

sudo apt-get update
sudo apt-get install -y \
    autoconf \
    automake \
    bison \
    build-essential \
    cmake \
    flex \
    libtool \
    pkg-config \
    python3 \
    zlib1g-dev

[[ -d emsdk ]] || git clone https://github.com/emscripten-core/emsdk
cd emsdk
./emsdk install latest
./emsdk activate latest
source emsdk_env.sh
cd ..

# Build wasm dependencies
mkdir -p ${DEPS_DIR}/lib

# Foma
cd ${DEPS_DIR}
if [ -f libfoma.a ]; then
  echo "Foma already built (wasm-deps/libfoma.a exists), skipping..."
else
  echo "Building Foma..."
  [ -d foma ] || git clone https://github.com/mhulden/foma.git
  cd foma/foma
  git pull
  emcmake cmake .
  emmake make -j$(nproc)
  cp libfoma.a ${DEPS_DIR}/lib/
fi

# OpenFst
cd ${DEPS_DIR}
if [ -f libfst.a ]; then
  echo "OpenFst already built (wasm-deps/libfst.a exists), skipping..."
else
  echo "Building OpenFst..."
  [ -d openfst ] || git clone https://github.com/TinoDidriksen/openfst.git
  cd openfst
  autoreconf -fiv
  emconfigure ./configure --enable-static --disable-shared
  emmake make -j$(nproc)
  cp src/lib/.libs/libfst.a ${DEPS_DIR}/lib/
  [ -d ${DEPS_DIR}/include/fst ] || ln -s ${DEPS_DIR}/openfst/src/include/fst ${DEPS_DIR}/include/
fi

# ICU
cd ${DEPS_DIR}
if [ -f lib/libicuuc.a ]; then
  echo "ICU already built (wasm-deps/lib/libicuuc.a exists), skipping..."
else
  LATEST_TAG=$(curl -s https://api.github.com/repos/unicode-org/icu/releases/latest | grep tag_name | cut -d '"' -f 4)
  echo "Latest ICU tag: $LATEST_TAG"
  # Extract version part (e.g., 77-1)
  ICU_VERSION_PART=${LATEST_TAG#release-}
  # Replace the first hyphen with an underscore (e.g., 77_1)
  ICU_VERSION_UNDERSCORE=${ICU_VERSION_PART/-/_}
  # get latest release source
  ICU_VERSION_MAJOR=$(echo ${ICU_VERSION_PART} | cut -d - -f 1)
  if [ ! -d icu ]; then
    INSTALL_DIR="$(pwd)/icu-static-install"
    # Construct the archive name
    ARCHIVE_NAME="icu4c-${ICU_VERSION_UNDERSCORE}-src.tgz"
    ARCHIVE_URL="https://github.com/unicode-org/icu/releases/download/${LATEST_TAG}/${ARCHIVE_NAME}"
    curl -L -o "$ARCHIVE_NAME" "$ARCHIVE_URL"
    tar -xf "$ARCHIVE_NAME"
  fi
  cd icu/source
  ./runConfigureICU Linux
  make -j$(nproc)

  # Build WASM ICU in a separate directory
  cd ${DEPS_DIR}/icu
  mkdir -p wasm-build
  cd wasm-build
  echo "Building WASM ICU library..."
  emconfigure ../source/runConfigureICU Linux \
    --prefix="${DEPS_DIR}" \
    --host=wasm32-unknown-emscripten \
    --disable-extras \
    --disable-layout \
    --disable-layoutex \
    --disable-samples \
    --disable-shared \
    --disable-tests \
    --disable-tools \
    --enable-static \
    --with-data-packaging=static \
    --with-cross-build="${DEPS_DIR}/icu/source"
  cp ../source/config/mh-linux ../source/config/mh-unknown  # Configure cannot detect emscripten platform; it suggested using linux template
  emmake make -j$(nproc)
  emmake make install

#######################################################################
# Manually build minimal libicudata.a with only character brkitr data #
#######################################################################
ICU_NATIVE_BUILD_DIR="${DEPS_DIR}/icu/source"
ICU_WASM_BUILD_DIR="${DEPS_DIR}/icu/wasm-build"
ICU_MIN_DATA_DIR="${DEPS_DIR}/icu/minimal-data-tmp"
FULL_DATA_FILE="${ICU_NATIVE_BUILD_DIR}/data/in/icudt${ICU_VERSION_MAJOR}l.dat"
MINIMAL_DAT_FILE="${ICU_MIN_DATA_DIR}/icudt${ICU_VERSION_MAJOR}l_minimal.dat"

# Ensure native tools are built
if [ ! -x "${ICU_NATIVE_BUILD_DIR}/bin/icupkg" ] || [ ! -x "${ICU_NATIVE_BUILD_DIR}/bin/genccode" ]; then
  echo "Error: Native ICU tools (icupkg, genccode) not found or not executable in ${ICU_NATIVE_BUILD_DIR}/bin"
  exit 1
fi
if [ ! -f "${FULL_DATA_FILE}" ]; then
    echo "Error: Full ICU data file not found at ${FULL_DATA_FILE}"
    # Attempt to find it elsewhere, common alternative location:
    ALT_FULL_DATA_FILE="${ICU_NATIVE_BUILD_DIR}/stubdata/icudt${ICU_VERSION_MAJOR}l.dat"
    if [ -f "${ALT_FULL_DATA_FILE}" ]; then
        echo "Found data file at alternative location: ${ALT_FULL_DATA_FILE}"
        FULL_DATA_FILE="${ALT_FULL_DATA_FILE}"
    else
        echo "Could not find ICU data file. Please check the ICU native build output."
        exit 1
    fi
fi

# Clean up previous attempts
rm -rf "${ICU_MIN_DATA_DIR}"
mkdir -p "${ICU_MIN_DATA_DIR}"

# List of essential data items for character break iteration and basic functionality
# Add more locales (e.g., res/en.res, res/de.res) or data types if needed.
DATA_ITEMS="brkitr/char.brk cnvalias.icu pool.res"
LIST_FILE="/tmp/minimal_list.txt"
echo "${DATA_ITEMS}" | tr ' ' '\n' > "${LIST_FILE}"

# Extract necessary items using native icupkg
echo "Extracting data items: ${DATA_ITEMS}"
# Extract items from the full data file into the minimal data directory
"${ICU_NATIVE_BUILD_DIR}/bin/icupkg" \
    --extract "${LIST_FILE}" \
    --destdir "${ICU_MIN_DATA_DIR}" \
    "${FULL_DATA_FILE}"
ls -R "${ICU_MIN_DATA_DIR}"

echo "Creating minimal data archive: ${MINIMAL_DAT_FILE}"
rm -f "${MINIMAL_DAT_FILE}"
"${ICU_NATIVE_BUILD_DIR}/bin/icupkg" \
    --type l \
    --add "${LIST_FILE}" \
    --sourcedir "${ICU_MIN_DATA_DIR}" \
    new \
    "${MINIMAL_DAT_FILE}"

# Check if the minimal data file was created
if [ ! -f "${MINIMAL_DAT_FILE}" ]; then
    echo "Error: icupkg failed to create ${MINIMAL_DAT_FILE}"
    exit 1
fi

# Compile libicudata.a from MINIMAL_DAT_FILE
MINIMAL_DATA_C_FILE="${ICU_MIN_DATA_DIR}/icudt${ICU_VERSION_MAJOR}l_minimal_dat.c"
MINIMAL_DATA_C_FILE="${ICU_MIN_DATA_DIR}/icudt${ICU_VERSION_MAJOR}l_dat.c"  # TODO DELETE ME
MINIMAL_DATA_O_FILE="${ICU_MIN_DATA_DIR}/icudt${ICU_VERSION_MAJOR}l_minimal_dat.o"
MINIMAL_DATA_O_FILE="${ICU_MIN_DATA_DIR}/icudt${ICU_VERSION_MAJOR}l_dat.o"  # TODO DELETE ME
MINIMAL_DATA_LIB_DEST="${DEPS_DIR}/lib/libicudata.a"

# Generate C code from the minimal data archive using native genccode
echo "Generating C source from minimal data: ${MINIMAL_DATA_C_FILE}"
"${ICU_NATIVE_BUILD_DIR}/bin/genccode" \
    --name icudt${ICU_VERSION_MAJOR}_dat \
    --destdir "${ICU_MIN_DATA_DIR}" \
    "${FULL_DATA_FILE}"  # TODO DELETE ME and uncomment the next line
    # "${MINIMAL_DAT_FILE}"

# Compile the generated C code to an object file using emcc
echo "Compiling data source with emcc: ${MINIMAL_DATA_O_FILE}"
emcc -c "${MINIMAL_DATA_C_FILE}" -o "${MINIMAL_DATA_O_FILE}"

# Archive the object file into libicudata.a using emar
echo "Archiving data object into: ${MINIMAL_DATA_LIB_DEST}"
emar rcs "${MINIMAL_DATA_LIB_DEST}" "${MINIMAL_DATA_O_FILE}"

# Optional: Clean up temporary directory
# rm -rf "${ICU_MIN_DATA_DIR}"

echo "Minimal ICU data library created successfully at ${MINIMAL_DATA_LIB_DEST}."

fi





# Build libhfst
cd ${HFST_DIR}

# if [ -f configure ]; then
#     autoreconf
# else
#     ./autogen.sh
# fi

echo "Configure with Emscripten"
emconfigure ./configure \
  --host=wasm32-unknown-emscripten \
  --with-sfst=no \
  --with-foma=yes \
  --with-openfst=yes \
  --enable-no-tools \
  --disable-load-so-entries \
  --with-readline=no \
  --with-icu=${DEPS_DIR} \
  CPPFLAGS="-I${DEPS_DIR}/include -I${DEPS_DIR}/foma/foma" \
  FOMA_CFLAGS="-I${DEPS_DIR}/foma/foma" \
  FOMA_LIBS="-L${DEPS_DIR} -lfoma" \
  LDFLAGS="-L${DEPS_DIR}/lib" \
  VERBOSE=1 \
  EMSCRIPTEN=1
# TODO: optimization with -O3 or -O4

echo "Build libhfst"
emmake make -C libhfst VERBOSE=1 -j$(nproc)

echo "Successfully completed!"
