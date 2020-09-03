#!/usr/bin/env bash

set -e -o pipefail

export LANG="en_US.UTF-8"

# distro code name
DISTRO=$(basename "$0")
DISTRO=${DISTRO%.*}

if [ "${DISTRO}" = 'centos7' ]; then
    MOCK_CFG='epel-7-x86_64'
    MOCK_PARAMS=''
    DIST_TAG='el7'
    GEMFILE_LOCK='CentOS7'
elif [ "${DISTRO}" = 'centos8' ]; then
    MOCK_CFG='epel-8-x86_64'
    MOCK_PARAMS=''
    DIST_TAG='el8'
    GEMFILE_LOCK='CentOS8'
elif [ "${DISTRO}" = 'fedora32' ]; then
    TEMPLATES='centos8'
    MOCK_CFG='fedora-32-x86_64'
    MOCK_PARAMS='--use-bootstrap-image'
    DIST_TAG='fc32'
    GEMFILE_LOCK='Fedora32'
else
    echo "ERROR: Invalid target '${DISTRO}'" >&2
    exit 1
fi

###

cd "$(dirname "$0")"

URL="$1"
PKG_VERSION=${2:-1}

SPEC='opennebula.spec'
TEMPLATES=${TEMPLATES:-${DISTRO}}
BUILD_DIR=$(mktemp -d)
BUILD_DIR_SPKG=$(mktemp -d)
PACKAGES_DIR=$(realpath "${PWD}")
SOURCES_DIR="${PACKAGES_DIR}/sources"

SOURCE=$(basename "${URL}")
PACKAGE=${SOURCE%.tar.gz}

NAME=$(echo "${PACKAGE}" | cut -d'-' -f1) # opennebula
VERSION=$(echo "${PACKAGE}" |cut -d'-' -f2) # 1.9.90
CONTACT=${CONTACT:-Unofficial Unsupported Build}
BASE_NAME="${NAME}-${VERSION}-${PKG_VERSION}"
GEMS_RELEASE="${VERSION}_${PKG_VERSION}.${DIST_TAG}"
GIT_VERSION=${GIT_VERSION:-not known}
DATE=$(date +'%a %b %d %Y')

# check for mock
if ! command -v mock >/dev/null 2>&1; then
    echo 'ERROR: Missing "mock" tool' >&2
    exit 1
fi

################################################################################
# Get all sources
################################################################################

cp "templates/${TEMPLATES}"/* "${BUILD_DIR_SPKG}"

shift || :
shift || :

echo '***** Prepare sources' >&2
for S in $URL "$@"; do
    case $S in
        http*)
            wget -P "${BUILD_DIR_SPKG}"/ -q "${S}"
            ;;
        *)
            LOCAL_URL=$(readlink -f "${S}" || :)
            if [ -z "$LOCAL_URL" ] ; then
                echo "ERROR: URL argument ('${S}') is not a valid URL or a file PATH" >&2
                exit 1
            fi
            cp "${LOCAL_URL}" "${BUILD_DIR_SPKG}"/
            ;;
    esac
done

cd "${BUILD_DIR_SPKG}"

# extra sources
wget -q http://downloads.opennebula.org/extra/xmlrpc-c.tar.gz
cp "${SOURCES_DIR}/build_opennebula.sh" .
cp "${SOURCES_DIR}/xml_parse_huge.patch" .

################################################################################
# Setup mock build environment
################################################################################

# use YUM http proxy
if egrep -q 'proxy\s*=' /etc/yum.conf; then
    http_proxy=$(egrep 'proxy\s*=' /etc/yum.conf | sed -e 's/^proxy\s*=\s*//')
    export http_proxy
fi

################################################################################
# Build Ruby gems
################################################################################

RUBYGEMS_REQ=''
if [[ "${BUILD_COMPONENTS}" =~ rubygems ]]; then
    echo '***** Downloading Ruby gems' >&2

    bash -x "${PACKAGES_DIR}/rubygems/download.sh" \
        "${BUILD_DIR_SPKG}/${SOURCE}" \
        "${GEMFILE_LOCK}" \
        "${BUILD_DIR_SPKG}/opennebula-rubygems-${VERSION}.tar"
fi

################################################################################
# Generate source package content
################################################################################

# process template
_BUILD_COMPONENTS_UC=${BUILD_COMPONENTS^^}
m4 -D_VERSION_="${VERSION}" \
    -D_PKG_VERSION_="${PKG_VERSION}" \
    -D_CONTACT_="${CONTACT}" \
    -D_DATE_="${DATE}" \
    -D_RUBYGEMS_REQ_="${RUBYGEMS_REQ}" \
    ${_BUILD_COMPONENTS_UC:+ -D_WITH_${_BUILD_COMPONENTS_UC//[[:space:]]/_ -D_WITH_}_} \
    "${SPEC}.m4" >"${SPEC}"

################################################################################
# Build the package
################################################################################

_BUILD_COMPONENTS_LC=${BUILD_COMPONENTS,,}
_WITH_COMPONENTS=${_BUILD_COMPONENTS_LC:+ --with ${_BUILD_COMPONENTS_LC//[[:space:]]/ --with }}

mock -r "${MOCK_CFG}" ${MOCK_PARAMS} --bootstrap-chroot --init

# build source package
echo '***** Building source package' >&2
MOCK_DIR_SPKG=$(mktemp -d)
mock -r "${MOCK_CFG}" -v \
    ${MOCK_PARAMS} \
    --bootstrap-chroot \
    --buildsrpm \
    --resultdir="${MOCK_DIR_SPKG}" \
    --spec "${SPEC}" \
    --sources "${BUILD_DIR_SPKG}" \
    --define "packager ${CONTACT}" \
    ${_WITH_COMPONENTS}

_SRPMS=$(ls "${MOCK_DIR_SPKG}/"*.src.rpm)
if [ "$(echo "${_SRPMS}" | wc -l)" -ne 1 ]; then
    echo "ERROR: Expected 1 source RPM, but got:" >&2
    echo "__START__${_SRPMS}__END__" >&2
    exit 1
fi

SRPM=$(basename "${_SRPMS}")
mkdir -p "${BUILD_DIR}/src/"
cp "${MOCK_DIR_SPKG}/${SRPM}" "${BUILD_DIR}/src/"
rm -rf "${MOCK_DIR_SPKG}"

# build binary package
echo '***** Building binary package' >&2
MOCK_DIR_PKG=$(mktemp -d)
mock -r "${MOCK_CFG}" -v \
    ${MOCK_PARAMS} \
    --bootstrap-chroot \
    --rebuild "${BUILD_DIR}/src/${SRPM}" \
    --resultdir="${MOCK_DIR_PKG}" \
    --define "packager ${CONTACT}" \
    --define "gitversion ${GIT_VERSION}" \
    ${_WITH_COMPONENTS}

rm -rf "${MOCK_DIR_PKG}"/*.src.rpm
cp "${MOCK_DIR_PKG}"/*.rpm "${BUILD_DIR}"
rm -rf "${MOCK_DIR_PKG}"

################################################################################
# Create archive with all packages
################################################################################

echo '***** Creating tar archive' >&2
cd "${BUILD_DIR}"
tar -czf "${BASE_NAME}.tar.gz" \
    --owner=root --group=root  \
    --transform "s,^,${BASE_NAME}/," \
    *

# copy tar to ~/tar
rm -rf ~/tar
mkdir -p ~/tar
cp -f "${BASE_NAME}.tar.gz" ~/tar

################################################################################
# Cleanups
################################################################################

rm -rf "${BUILD_DIR}" "${BUILD_DIR_SPKG}"
