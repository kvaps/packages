#!/usr/bin/env bash

set -e -o pipefail
set -x

BUILD_DIR="${PWD}"

# compilation minimum if nothing got from package builder
export CXXFLAGS=${CXXFLAGS:--fPIC}
export CFLAGS=${CFLAGS:-Wno-error=format-security}

# dump compiler flag
echo '***** Compilation Flags' >&2
echo "- CFLAGS='${CFLAGS}'" >&2
echo "- CXXFLAGS='${CXXFLAGS}'" >&2
echo "- CPPFLAGS='${CPPFLAGS}'" >&2
echo "- LDFLAGS='${LDFLAGS}'" >&2


################################################################################

# Compile xmlrpc-c
echo '***** Build XML-RPC for C and C++ library' >&2

if [ -f "${XMLRPC_DIR}xmlrpc-c.tar.gz" ]; then
(
    tar xzvf "${XMLRPC_DIR}xmlrpc-c.tar.gz"
    mv xmlrpc-c ..
    mv "${XMLRPC_DIR}xml_parse_huge.patch" "${BUILD_DIR}/.."
)
fi

cd ../xmlrpc-c
patch -p1 < "${BUILD_DIR}/../xml_parse_huge.patch"
./configure --prefix="${PWD}/install" --enable-libxml2-backend

# This is a dirty workaround how to skip building shared libraries
# and avoid incompatible PIE compile option.
echo 'MUST_BUILD_SHLIB = NO'   >> config.mk
echo 'MUST_BUILD_SHLIBLE = NO' >> config.mk
echo 'SHARED_LIB_TYPE = NONE'  >> config.mk

CFLAGS="${CFLAGS} -Wno-error=format-security" make
make install

# Add xmlrpc-c libraries bin dir to the path
export PATH=$PWD/install/bin:$PATH


################################################################################

# Compile OpenNebula
echo '***** Build OpenNebula' >&2

cd "${BUILD_DIR}"

"${SCONS:-scons}" -j2 \
    mysql=yes \
    postgresql=yes \
    xmlrpc="${BUILD_DIR}/../xmlrpc-c/install" \
    new_xmlrpc=yes \
    context=yes\
    "$@"
