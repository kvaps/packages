#!/bin/bash

# -------------------------------------------------------------------------- #
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

set -e

SCRIPTS_DIR=${SCRIPTS_DIR:-$(dirname "$0")}

SOURCE=$1
TARGET=$2
OUTPUT=$3

shift 3 || :

###

# get Gemfile, Gemfile.lock
TMP_GEMFILE="$(mktemp)"
tar -xf "${SOURCE}" \
    --wildcards --no-wildcards-match-slash \
    -O '*/share/install_gems/Gemfile' \
    > "${TMP_GEMFILE}"

TMP_GEMFILE_LOCK="$(mktemp)"
tar -xf "${SOURCE}" \
    --wildcards --no-wildcards-match-slash \
    -O "*/share/install_gems/${TARGET}/Gemfile.lock" \
    > "${TMP_GEMFILE_LOCK}"

# download all gems as archive
"${SCRIPTS_DIR}"/gemfile2tar \
    "${TMP_GEMFILE}" \
    "${TMP_GEMFILE_LOCK}" \
    "${OUTPUT}"

# cleanups
rm "${TMP_GEMFILE}" "${TMP_GEMFILE_LOCK}"
