#!/bin/bash

# -------------------------------------------------------------------------- #
# Copyright 2019, Erich Cernaj                                               #
# Copyright 2002-2019, OpenNebula Project, OpenNebula Systems                #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

set -e -o pipefail

if [ $# -gt 1 ]; then
    echo "Syntax: $(basename "$0") [debian|redhat]" >&2
    exit 1
fi

# detect target
if command -v dpkg >/dev/null; then
    OPTION=${1:-debian}
elif command -v rpm >/dev/null; then
    OPTION=${1:-redhat}
fi

# Install packages
case "${OPTION}" in
    'debian')
        echo "Install build dependencies for ${OPTION}"

        export DEBIAN_FRONTEND=noninteractive

        apt-get -y install \
            ruby-dev make gcc libsqlite3-dev libcurl4-openssl-dev \
            rake libxml2-dev libxslt1-dev patch g++ build-essential \
            libssl-dev libaugeas-dev \
            >/dev/null

        # default-libmysqlclient-dev OR libmysqlclient-dev
        apt-get -y install default-libmysqlclient-dev >/dev/null 2>&1 || \
            apt-get -y install libmysqlclient-dev >/dev/null

        # workaround missing libxml2 headers on some Ubuntu/Debian
        ln -s /usr/include/libxml2/libxml /usr/include/libxml || :
        ;;
    'redhat')
        echo "Install build dependencies for ${OPTION}"

        yum -y install ruby-devel make gcc sqlite-devel mysql-devel \
            openssl-devel curl-devel rubygem-rake libxml2-devel \
            libxslt-devel patch expat-devel gcc-c++ rpm-build augeas-devel \
            >/dev/null
        ;;
    *)
        echo "ERROR: Unknown target ${OPTION}" >&2
        exit 1
        ;;
esac

# Install Bundler
if ! command -v bundler >/dev/null; then
    echo 'Install Bundler'
    gem install bundler --version '< 2' >/dev/null
fi
