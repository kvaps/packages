#!/bin/sh

# ---------------------------------------------------------------------------- #
# Copyright 2020, OpenNebula Project, OpenNebula Systems                       #
#                                                                              #
# Licensed under the Apache License, Version 2.0 (the "License"); you may      #
# not use this file except in compliance with the License. You may obtain      #
# a copy of the License at                                                     #
#                                                                              #
# http://www.apache.org/licenses/LICENSE-2.0                                   #
#                                                                              #
# Unless required by applicable law or agreed to in writing, software          #
# distributed under the License is distributed on an "AS IS" BASIS,            #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.     #
# See the License for the specific language governing permissions and          #
# limitations under the License.                                               #
# ---------------------------------------------------------------------------- #

set -e

#
# image params
#

export OPENNEBULA_FRONTEND_SERVICE="${OPENNEBULA_FRONTEND_SERVICE:-all}"
export OPENNEBULA_FRONTEND_SSH_HOSTNAME="${OPENNEBULA_FRONTEND_SSH_HOSTNAME:-opennebula-frontend}"
export OPENNEBULA_ONED_HOSTNAME="${OPENNEBULA_ONED_HOSTNAME:-${OPENNEBULA_FRONTEND_SSH_HOSTNAME}}"
export OPENNEBULA_ONED_APIPORT="${OPENNEBULA_ONED_APIPORT:-2633}"
export OPENNEBULA_ONED_VMM_EXEC_KVM_EMULATOR
export OPENNEBULA_ONED_TLSPROXY_APIPORT
export OPENNEBULA_ONEFLOW_HOSTNAME="${OPENNEBULA_ONEFLOW_HOSTNAME:-${OPENNEBULA_FRONTEND_SSH_HOSTNAME}}"
export OPENNEBULA_ONEFLOW_APIPORT="${OPENNEBULA_ONEFLOW_APIPORT:-2474}"
export OPENNEBULA_ONEFLOW_TLSPROXY_APIPORT
export OPENNEBULA_ONEGATE_HOSTNAME="${OPENNEBULA_ONEGATE_HOSTNAME:-${OPENNEBULA_FRONTEND_SSH_HOSTNAME}}"
export OPENNEBULA_ONEGATE_APIPORT="${OPENNEBULA_ONEGATE_APIPORT:-5030}"
export OPENNEBULA_ONEGATE_TLSPROXY_APIPORT
export OPENNEBULA_MEMCACHED_HOSTNAME="${OPENNEBULA_MEMCACHED_HOSTNAME:-${OPENNEBULA_FRONTEND_SSH_HOSTNAME}}"
export OPENNEBULA_MEMCACHED_APIPORT="${OPENNEBULA_MEMCACHED_APIPORT:-11211}"
export OPENNEBULA_FIREEDGE_HTTPPORT="${OPENNEBULA_FIREEDGE_HTTPPORT:-2616}"
export OPENNEBULA_FIREEDGE_VNCPORT="${OPENNEBULA_FIREEDGE_VNCPORT:-4822}"
export OPENNEBULA_SUNSTONE_HTTPD="${OPENNEBULA_SUNSTONE_HTTPD:-yes}"
# NOTE: sunstone with apache requires memcached - so that is why this default
export OPENNEBULA_SUNSTONE_MEMCACHED="${OPENNEBULA_SUNSTONE_MEMCACHED:-${OPENNEBULA_SUNSTONE_HTTPD}}"
export OPENNEBULA_SUNSTONE_HTTPPORT="${OPENNEBULA_SUNSTONE_HTTPPORT:-9869}"
export OPENNEBULA_SUNSTONE_HTTPSPORT="${OPENNEBULA_SUNSTONE_HTTPSPORT:-443}"
export OPENNEBULA_SUNSTONE_VNCPORT="${OPENNEBULA_SUNSTONE_VNCPORT:-29876}"
# TODO: this is not ideal - but I need to match and/or redirect these ports...
export OPENNEBULA_SUNSTONE_PUBLISHED_HTTPPORT="${OPENNEBULA_SUNSTONE_PUBLISHED_HTTPPORT:-9869}"
export OPENNEBULA_SUNSTONE_PUBLISHED_HTTPSPORT="${OPENNEBULA_SUNSTONE_PUBLISHED_HTTPSPORT:-443}"
export OPENNEBULA_SUNSTONE_HTTP_REDIRECT="${OPENNEBULA_SUNSTONE_HTTP_REDIRECT:-no}"
export OPENNEBULA_SUNSTONE_HTTPS_ONLY="${OPENNEBULA_SUNSTONE_HTTPS_ONLY:-no}"
export OPENNEBULA_SUNSTONE_HTTPS_ENABLED="${OPENNEBULA_SUNSTONE_HTTPS_ENABLED:-yes}"
export OPENNEBULA_TLS_PROXY_ENABLED="${OPENNEBULA_TLS_PROXY_ENABLED:-no}"
export OPENNEBULA_TLS_DOMAIN_LIST="${OPENNEBULA_TLS_DOMAIN_LIST:-*}"
export OPENNEBULA_TLS_VALID_DAYS="${OPENNEBULA_TLS_VALID_DAYS:-365}"
export OPENNEBULA_TLS_CERT_BASE64
export OPENNEBULA_TLS_KEY_BASE64
export OPENNEBULA_TLS_CERT
export OPENNEBULA_TLS_KEY
# TODO: oneadmin is hardcoded on the installation - a change here would only broke things
#export ONEADMIN_USERNAME="${ONEADMIN_USERNAME:-oneadmin}"
export ONEADMIN_USERNAME="oneadmin"
export ONEADMIN_PASSWORD
export ONEADMIN_SSH_PRIVKEY
export ONEADMIN_SSH_PUBKEY
export MYSQL_HOST="${MYSQL_HOST:-${OPENNEBULA_FRONTEND_SSH_HOSTNAME}}"
export MYSQL_PORT="${MYSQL_PORT:-3306}"
export MYSQL_DATABASE="${MYSQL_DATABASE:-opennebula}"
export MYSQL_USER="${MYSQL_USER:-oneadmin}"
export MYSQL_PASSWORD
export MYSQL_ROOT_PASSWORD

#
# globals
#

PASSWORD_LENGTH=16

###############################################################################
# functions
#

msg()
{
    echo "[ONEDOCKER]: $*"
}

err()
{
    echo "[ONEDOCKER] [!] ERROR: $*"
}

gen_password()
(
    pw_length="${1:-16}"
    new_pw=''

    while [ "$(echo $new_pw | wc -c)" -lt "$pw_length" ] ; do
        new_pw="${new_pw}$(openssl rand -base64 ${pw_length} | tr -dc '[:alnum:]')"
    done

    echo "$new_pw" | cut -c1-${pw_length}
)

is_true()
(
    _value=$(echo "$1" | tr '[:upper:]' '[:lower:]')

    case "$_value" in
        yes|true|1)
            return 0
            ;;
    esac

    return 1
)

# Feed augtool commands on stdin of this function:
#
# this will make augtool little faster by using only needed lenses and executing
# commands in one run
# args: <absolute-path-to-the-edited-file>
augtool_helper()
{
    augtool --noload --interactive <<EOF
rm /augeas/load/*["${1}"!~glob(incl) or "${1}"=~glob(excl)]
load
set /augeas/context /files${1}
$(cat)
save
quit
EOF
}

# IMPORTANT!
#
# This is mandatory - before opennebula service is started it needs to have the
# current password of the oneadmin user in ~oneadmin/.one/one_auth. If it is
# the first run then it will be generated.
#
# The issue manifests when the container is restarted - this whole directory
# will be lost. That happens due to the containers being stateless *BUT* if
# this is not the first run then the password is already stored in database and
# we will have possibly newly generated password which will not match the one
# in the database.
#
# For these reasons we need to have a volume:
prepare_oneadmin_data()
{
    # ensure the existence of our auth directory
    if ! [ -d /oneadmin/auth_data/auth ] ; then
        mkdir -p /oneadmin/auth_data/auth
    fi

    # store the password if not already there
    if ! [ -f /oneadmin/auth_data/auth/one_auth ] ; then
        if [ -z "$ONEADMIN_PASSWORD" ] ; then
            msg "EMPTY 'ONEADMIN_PASSWORD': GENERATE RANDOM"
            ONEADMIN_PASSWORD=$(gen_password ${PASSWORD_LENGTH})
        fi
        echo "${ONEADMIN_USERNAME}:${ONEADMIN_PASSWORD}" \
            > /oneadmin/auth_data/auth/one_auth
    fi

    # and ensure the correct permissions
    chown "${ONEADMIN_USERNAME}:" /oneadmin
    chown -R "${ONEADMIN_USERNAME}:" /oneadmin/auth_data/auth
    chmod 0700 /oneadmin/auth_data/auth
}

link_oneadmin_auth()
{
    # TODO: can we wait for this prerequisite elsewhere?
    ## ensure the existence of our auth directory
    #if ! [ -d /oneadmin/auth_data/auth ] ; then
    #    err "We need '/oneadmin/auth_data/auth'"
    #    exit 1
    #fi

    # remove .one if not the correct symlink
    if ! [ -L /var/lib/one/.one ] ; then
        rm -rf /var/lib/one/.one
    elif [ "$(readlink /var/lib/one/.one)" != /oneadmin/auth_data/auth ] ; then
        unlink /var/lib/one/.one
    fi

    # symlink oneadmin's auth dir into the volume
    if ! [ -L /var/lib/one/.one ] ; then
        ln -s /oneadmin/auth_data/auth /var/lib/one/.one
    fi
}

link_oneadmin_ssh()
{
    # TODO: can we wait for this prerequisite elsewhere?
    ## ensure the existence of our ssh directory
    #if ! [ -d /oneadmin/ssh_data/ssh ] ; then
    #    err "We need '/oneadmin/ssh_data/ssh'"
    #    exit 1
    #fi

    # remove .ssh if not the correct symlink
    if ! [ -L /var/lib/one/.ssh ] ; then
        rm -rf /var/lib/one/.ssh
    elif [ "$(readlink /var/lib/one/.ssh)" != /oneadmin/ssh_data/ssh ] ; then
        unlink /var/lib/one/.ssh
    fi

    # symlink oneadmin's ssh config dir into the volume
    if ! [ -L /var/lib/one/.ssh ] ; then
        ln -s /oneadmin/ssh_data/ssh /var/lib/one/.ssh
    fi
}

switch_to_pub_ssh_data()
{
    # NOTE: this expects that it is ran AFTER link_oneadmin_ssh

    if [ "$(readlink /var/lib/one/.ssh)" != /oneadmin/ssh_pub_data/ssh ] ; then
        unlink /var/lib/one/.ssh
    fi

    # symlink oneadmin's ssh config dir into the pub_ssh_data volume
    if ! [ -L /var/lib/one/.ssh ] ; then
        ln -s /oneadmin/ssh_pub_data/ssh /var/lib/one/.ssh
    fi
}

link_onedata()
{
    # remove datastores if not the correct symlink
    if ! [ -L /var/lib/one/datastores ] ; then
        rm -rf /var/lib/one/datastores
    elif [ "$(readlink /var/lib/one/datastores)" != /data/datastores ] ; then
        unlink /var/lib/one/datastores
    fi

    # symlink datastores into the volume
    if ! [ -L /var/lib/one/datastores ] ; then
        ln -s /data/datastores /var/lib/one/datastores
    fi
}

create_oneadmin_tmpfiles()
{
    systemd-tmpfiles --create /lib/tmpfiles.d/opennebula-common.conf || :
}

restore_ssh_host_keys()
{
    # create new or restore saved ssh host keys
    if ! [ -d /data/ssh_host_keys ] ; then
        # we have no keys saved
        mkdir -p /data/ssh_host_keys

        # force recreating of new host keys
        rm -f /etc/ssh/ssh_host_*
        ssh-keygen -A

        # save the keys
        cp -a /etc/ssh/ssh_host_* /data/ssh_host_keys/
    else
        # restore the saved ssh host keys
        cp -af /data/ssh_host_keys/ssh_host_* /etc/ssh/
    fi
}

prepare_ssh()
{
    # ensure the existence of ssh directory
    if ! [ -d /oneadmin/ssh_data/ssh ] ; then
        mkdir -p /oneadmin/ssh_data/ssh
    fi

    # if no ssh config is present then use the default
    if ! [ -f /oneadmin/ssh_data/ssh/config ] ; then
        cat /usr/share/one/ssh/config > /oneadmin/ssh_data/ssh/config
        chmod 0644 /oneadmin/ssh_data/ssh/config
    fi

    # copy the custom ssh key-pair
    _private_key_path=
    _public_key_path=
    _custom_key=no
    if [ -n "$ONEADMIN_SSH_PRIVKEY" ] && [ -n "$ONEADMIN_SSH_PUBKEY" ] ; then
        if [ -f "$ONEADMIN_SSH_PRIVKEY" ] && [ -f "$ONEADMIN_SSH_PUBKEY" ] ; then
            _custom_key=yes
            _privkey=$(basename "$ONEADMIN_SSH_PRIVKEY")
            _pubkey=$(basename "$ONEADMIN_SSH_PUBKEY")
            _private_key_path="/oneadmin/ssh_data/ssh/${_privkey}"
            _public_key_path="/oneadmin/ssh_data/ssh/${_pubkey}"

            cat "$ONEADMIN_SSH_PRIVKEY" > "${_private_key_path}"
            chmod 0600 "${_private_key_path}"

            cat "$ONEADMIN_SSH_PUBKEY" > "${_public_key_path}"
            chmod 0644 "${_public_key_path}"

            cat "${_public_key_path}" > /oneadmin/ssh_data/ssh/authorized_keys
            chmod 0644 /oneadmin/ssh_data/ssh/authorized_keys
        fi
    fi

    # generate ssh key-pair if no custom one is provided
    if [ "$_custom_key" != 'yes' ] ; then
        _private_key_path="/oneadmin/ssh_data/ssh/id_rsa"
        _public_key_path="/oneadmin/ssh_data/ssh/id_rsa.pub"

        if ! [ -f "${_private_key_path}" ] || ! [ -f "${_public_key_path}" ] ; then
            rm -f "${_private_key_path}" "${_public_key_path}"
            ssh-keygen -N '' -f "${_private_key_path}"
        fi

        cat "${_public_key_path}" > /oneadmin/ssh_data/ssh/authorized_keys
        chmod 0644 /oneadmin/ssh_data/ssh/authorized_keys
    fi

    chown -R "${ONEADMIN_USERNAME}:" /oneadmin/ssh_data/ssh
    chmod 0700 /oneadmin/ssh_data/ssh

    # store a copy of the authorized_keys and ssh config aside for ssh
    # container to pick it up
    mkdir -p /oneadmin/ssh_pub_data/ssh
    chmod 0700 /oneadmin/ssh_pub_data/ssh
    chown -R "${ONEADMIN_USERNAME}:" /oneadmin/ssh_pub_data/ssh
    if ! [ -f /oneadmin/ssh_pub_data/ssh/authorized_keys ] ; then
        cp -a /oneadmin/ssh_data/ssh/authorized_keys /oneadmin/ssh_pub_data/ssh/
    fi
    if ! [ -f /oneadmin/ssh_pub_data/ssh/config ] ; then
        cp -a /oneadmin/ssh_data/ssh/config /oneadmin/ssh_pub_data/ssh/
    fi
}

prepare_cert()
(
    # ensure the existence of cert_data directory
    if ! [ -d /cert_data ] ; then
        mkdir -p /cert_data
    fi

    # internal filepaths can be hardcoded - only the content is variable
    _cert_path="/cert_data/one.crt"
    _key_path="/cert_data/one.key"
    _cert_info_path="/cert_data/one.txt"

    # copy the custom certificate
    _custom_cert=no
    if [ -n "$OPENNEBULA_TLS_CERT_BASE64" ] && [ -n "$OPENNEBULA_TLS_KEY_BASE64" ] ; then
        _custom_cert=yes

        if ! echo "$OPENNEBULA_TLS_CERT_BASE64" | base64 -d > "${_cert_path}" ; then
            err "'OPENNEBULA_TLS_CERT_BASE64' does not have a base64 value - ABORT"
            return 1
        fi
        chmod 0644 "${_cert_path}"

        if ! echo "$OPENNEBULA_TLS_KEY_BASE64" | base64 -d > "${_key_path}" ; then
            err "'OPENNEBULA_TLS_KEY_BASE64' does not have a base64 value - ABORT"
            return 1
        fi
        chmod 0600 "${_key_path}"
    elif [ -n "$OPENNEBULA_TLS_CERT" ] && [ -n "$OPENNEBULA_TLS_KEY" ] ; then
        if [ -f "$OPENNEBULA_TLS_CERT" ] && [ -f "$OPENNEBULA_TLS_KEY" ] ; then
            _custom_cert=yes

            cat "$OPENNEBULA_TLS_CERT" > "${_cert_path}"
            chmod 0644 "${_cert_path}"

            cat "$OPENNEBULA_TLS_KEY" > "${_key_path}"
            chmod 0600 "${_key_path}"
        fi
    fi

    # generate self-signed certificate if no custom one is provided
    if [ "$_custom_cert" != 'yes' ] ; then
        # if we already created a cert and the cert params are unchanged then
        # we do not wish to generate a new one...
        if [ -f "${_cert_path}" ] && [ -f "${_key_path}" ] ; then
            # TODO: this should be rewritten by inspecting the actual cert and
            # not rely onto this info file...but I was lazy to parse it (it can
            # have different output on different systems and with different
            # versions of openssl command)
            if [ -f "${_cert_info_path}" ] ; then
                _new_cert_info=$(cat <<EOF
DNS = ${OPENNEBULA_TLS_DOMAIN_LIST}
DAYS = ${OPENNEBULA_TLS_VALID_DAYS}
EOF
                )
                _new_cert_info_hash=$(echo "${_new_cert_info}" | sha256sum)
                _old_cert_info_hash=$(sha256sum < "${_cert_info_path}")

                if [ "$_new_cert_info_hash" = "$_old_cert_info_hash" ] ; then
                    # the cert does not need to be generated again
                    return 0
                else
                    # store the new info
                    echo "$_new_cert_info" > "$_cert_info_path"
                fi
            fi
        fi

        # we remove the leftover old cert in the internal path
        rm -f "${_cert_path}" "${_key_path}"

        # we either use a user provided domain list or we will default to the
        # asterisk: *
        #
        # this is defined at the top of this script in the params section

        # exploit the shell argument array
        set -f
        set -- ${OPENNEBULA_TLS_DOMAIN_LIST}
        set +f
        _cn="${1}"
        shift

        # loop over the rest of the names to create a valid list prefixed
        # with 'DNS:' to be used as a value for subjectAltName
        _alt=
        for _name in $* ; do
            _alt="${_alt}${_alt:+,} DNS:${_name}"
        done

        # TODO: this can be improved (support for more configuration options?)
        # + rewrite this whole section with a config file in mind which will
        # also deduplicate this openssl command
        if [ -n "$_alt" ] ; then
            openssl req -new -newkey rsa:4096 -x509 -sha256 -nodes \
                -days "${OPENNEBULA_TLS_VALID_DAYS}" \
                -subj "/CN=${_cn}" \
                -addext "subjectAltName=${_alt}" \
                -out "${_cert_path}" \
                -keyout "${_key_path}"
        else
            openssl req -new -newkey rsa:4096 -x509 -sha256 -nodes \
                -days "${OPENNEBULA_TLS_VALID_DAYS}" \
                -subj "/CN=${_cn}" \
                -out "${_cert_path}" \
                -keyout "${_key_path}"
        fi

    fi

    chown -R "${ONEADMIN_USERNAME}:" /cert_data
    chmod 0700 /cert_data
)

prepare_onedata()
{
    # ensure the existence of the datastores directory
    if ! [ -d /data/datastores ] ; then
        mkdir -p /data/datastores
    fi

    # and ensure the correct permissions
    chown -R "${ONEADMIN_USERNAME}:" /data/datastores
    chmod 0750 /data/datastores
}

configure_tlsproxy()
(
    _name=
    _accept_port=
    _connect_port=

    case "$1" in
        oned)
            _name="$1"
            _accept_port="${OPENNEBULA_ONED_TLSPROXY_APIPORT}"
            _connect_port="${OPENNEBULA_ONED_APIPORT}"
            ;;
        onegate)
            _name="$1"
            _accept_port="${OPENNEBULA_ONEGATE_TLSPROXY_APIPORT}"
            _connect_port="${OPENNEBULA_ONEGATE_APIPORT}"
            ;;
        oneflow)
            _name="$1"
            _accept_port="${OPENNEBULA_ONEFLOW_TLSPROXY_APIPORT}"
            _connect_port="${OPENNEBULA_ONEFLOW_APIPORT}"
            ;;
        *)
            err "UNKNOWN TLS PROXY SERVICE '${1}' - ABORT"
            exit 1
            ;;
    esac

    if [ -f /cert_data/one.crt ] && [ -f /cert_data/one.key ] ; then
        cat > "/etc/stunnel/conf.d/${_name}.conf" <<EOF
[${_name}]
accept = ${_accept_port}
connect = ${_connect_port}
cert = /cert_data/one.crt
key = /cert_data/one.key
EOF
    else
        err "TLS PROXY REQUESTED BUT NO CERTS PROVIDED - ABORT"
        exit 1
    fi
)

configure_oned()
{
    # setup hostname and port
    augtool_helper /etc/one/oned.conf <<EOF
set HOSTNAME '"${OPENNEBULA_FRONTEND_SSH_HOSTNAME}"'
set PORT '"${OPENNEBULA_ONED_APIPORT}"'
EOF

    # setup hypervisor specifics
    if [ -n "${OPENNEBULA_ONED_VMM_EXEC_KVM_EMULATOR}" ] ; then
        augtool_helper /etc/one/vmm_exec/vmm_exec_kvm.conf <<EOF
set EMULATOR '"${OPENNEBULA_ONED_VMM_EXEC_KVM_EMULATOR}"'
EOF
    fi

    # add new DB connections based on the passed env. variables
    augtool_helper /etc/one/oned.conf <<EOF
rm DB
set DB/BACKEND '"mysql"'
set DB/SERVER  '"${MYSQL_HOST}"'
set DB/PORT    '${MYSQL_PORT}'
set DB/USER    '"${MYSQL_USER}"'
set DB/PASSWD  '"${MYSQL_PASSWORD}"'
set DB/DB_NAME '"${MYSQL_DATABASE}"'
EOF

    # add onegate endpoint
    if is_true "${OPENNEBULA_TLS_PROXY_ENABLED}" ; then
        augtool_helper /etc/one/oned.conf <<EOF
set ONEGATE_ENDPOINT '"https://${OPENNEBULA_ONEGATE_HOSTNAME}:${OPENNEBULA_ONEGATE_PUBLISHED_APIPORT}"'
EOF
    else
        augtool_helper /etc/one/oned.conf <<EOF
set ONEGATE_ENDPOINT '"http://${OPENNEBULA_ONEGATE_HOSTNAME}:${OPENNEBULA_ONEGATE_PUBLISHED_APIPORT}"'
EOF
    fi
}

configure_sunstone()
{
    sed -i \
        -e "s#^:one_xmlrpc:.*#:one_xmlrpc: http://${OPENNEBULA_ONED_HOSTNAME}:${OPENNEBULA_ONED_APIPORT}/RPC2#" \
        -e "s#^:oneflow_server:.*#:oneflow_server: http://${OPENNEBULA_ONEFLOW_HOSTNAME}:${OPENNEBULA_ONEFLOW_APIPORT}#" \
        -e "s#^:port:.*#:port: ${OPENNEBULA_SUNSTONE_HTTPPORT}#" \
        -e "s#^:vnc_proxy_port:.*#:vnc_proxy_port: ${OPENNEBULA_SUNSTONE_VNCPORT}#" \
        -e "s#^:tmpdir:.*#:tmpdir: /var/tmp/sunstone/shared#" \
        /etc/one/sunstone-server.conf

    # enable vnc over ssl when https is required and certs provided
    if is_true "${OPENNEBULA_SUNSTONE_HTTPS_ENABLED}" ; then
        if [ -f /cert_data/one.crt ] && [ -f /cert_data/one.key ] ; then
            if is_true "${OPENNEBULA_SUNSTONE_HTTPS_ONLY}" ; then
                _wss="only"
            else
                _wss="yes"
            fi

            sed -i \
                -e "s#^:vnc_proxy_support_wss:.*#:vnc_proxy_support_wss: ${_wss}#" \
                -e "s#^:vnc_proxy_cert:.*#:vnc_proxy_cert: /cert_data/one.crt#" \
                -e "s#^:vnc_proxy_key:.*#:vnc_proxy_key: /cert_data/one.key#" \
                /etc/one/sunstone-server.conf
        else
            err "HTTPS REQUESTED BUT NO CERTS PROVIDED - ABORT"
            exit 1
        fi
    fi

    # shared tmpdir with oned
    mkdir -p /var/tmp/sunstone/shared
    chown -R oneadmin:oneadmin /var/tmp/sunstone/shared
    chmod 0755 /var/tmp/sunstone/shared

    # TODO: remove this when sunstone is fixed:
    # https://github.com/OpenNebula/one/issues/5019
    sed -i 's/^\([[:space:]]*webauthn_avail[[:space:]]*\)=.*/\1= false/' \
        /usr/lib/one/sunstone/sunstone-server.rb

    if is_true "${OPENNEBULA_SUNSTONE_HTTPD}" ; then
        mkdir -p /run/passenger
        chown oneadmin:oneadmin /run/passenger
        chmod 0755 /run/passenger

        systemd-tmpfiles --create /lib/tmpfiles.d/passenger.conf || :

        mkdir -p /run/httpd
        chown root:apache /run/httpd
        chmod 0710 /run/httpd

        # enable HTTPS VirtualHost
        if is_true "${OPENNEBULA_SUNSTONE_HTTPS_ENABLED}" ; then
            cp -a /etc/httpd/conf.d/opennebula-https.conf-disabled \
                /etc/httpd/conf.d/opennebula-https.conf
        elif is_true "${OPENNEBULA_SUNSTONE_HTTPS_ONLY}" ; then
            err "ONLY HTTPS REQUESTED BUT 'OPENNEBULA_SUNSTONE_HTTPS_ENABLED' IS FALSE - ABORT"
            exit 1
        elif is_true "${OPENNEBULA_SUNSTONE_HTTP_REDIRECT}" ; then
            err "HTTP REDIRECT REQUESTED BUT 'OPENNEBULA_SUNSTONE_HTTPS_ENABLED' IS FALSE - ABORT"
            exit 1
        fi

        # enable HTTP VirtualHost
        if ! is_true "${OPENNEBULA_SUNSTONE_HTTPS_ONLY}" ; then
            # the if conditional in the httpd conf will expect yes or true
            if is_true "${OPENNEBULA_SUNSTONE_HTTP_REDIRECT}" ; then
                OPENNEBULA_SUNSTONE_HTTP_REDIRECT='yes'
            fi

            cp -a /etc/httpd/conf.d/opennebula-http.conf-disabled \
                /etc/httpd/conf.d/opennebula-http.conf
        fi
    elif is_true "${OPENNEBULA_SUNSTONE_HTTPS_ENABLED}" ; then
        err "HTTPS REQUESTED BUT 'OPENNEBULA_SUNSTONE_HTTPD' IS FALSE - ABORT"
        exit 1
    elif is_true "${OPENNEBULA_SUNSTONE_HTTPS_ONLY}" ; then
        err "ONLY HTTPS REQUESTED BUT 'OPENNEBULA_SUNSTONE_HTTPS_ENABLED' IS FALSE - ABORT"
        exit 1
    fi

    if is_true "${OPENNEBULA_SUNSTONE_MEMCACHED}" ; then
        sed -i \
            -e "s#^:sessions:.*#:sessions: 'memcache'#" \
            -e "s#^:memcache_host:.*#:memcache_host: ${OPENNEBULA_MEMCACHED_HOSTNAME}#" \
            -e "s#^:memcache_port:.*#:memcache_port: ${OPENNEBULA_MEMCACHED_APIPORT}#" \
            /etc/one/sunstone-server.conf
    elif is_true "${OPENNEBULA_SUNSTONE_HTTPS_ENABLED}" ; then
        err "HTTPS REQUESTED BUT 'OPENNEBULA_SUNSTONE_MEMCACHED' IS FALSE - ABORT"
        exit 1
    fi
}

configure_fireedge()
{
    cat > /etc/one/fireedge-server.conf <<EOF
################################################################################
# Server Configuration
################################################################################

# System log (Morgan) prod or dev
LOG: prod

# Enable cors (cross-origin resource sharing)
CORS: true

# Fireedge server port
PORT: ${OPENNEBULA_FIREEDGE_HTTPPORT}

# OpenNebula Zones: use it if you have oned and fireedge on different servers
DEFAULT_ZONE:
  ID: '0'
  NAME: 'OpenNebula'
  RPC: 'http://${OPENNEBULA_ONED_HOSTNAME}:${OPENNEBULA_ONED_APIPORT}/RPC2'

# Flow Server: use it if you have flow-server and fireedge on different servers
ONE_FLOW_SERVER:
  PROTOCOL: 'http'
  HOST: '${OPENNEBULA_ONEFLOW_HOSTNAME}'
  POST: ${OPENNEBULA_ONEFLOW_APIPORT}

# JWT life time (days)
LIMIT_TOKEN:
  MIN: 14
  MAX: 30

# VMRC
#VMRC:
#  TARGET: 'http://opennebula.io'

# Guacamole: use it if you have the Guacd in other server or port
GUACD:
  PORT: ${OPENNEBULA_FIREEDGE_VNCPORT}
  HOST: '127.0.0.1'

EOF
}

configure_scheduler()
{
    augtool_helper /etc/one/sched.conf <<EOF
set ONE_XMLRPC '"http://${OPENNEBULA_ONED_HOSTNAME}:${OPENNEBULA_ONED_APIPORT}/RPC2"'
EOF
}

configure_oneflow()
{
    sed -i \
        -e "s#^:one_xmlrpc:.*#:one_xmlrpc: http://${OPENNEBULA_ONED_HOSTNAME}:${OPENNEBULA_ONED_APIPORT}/RPC2#" \
        -e "s#^:host:.*#:host: 0.0.0.0#" \
        -e "s#^:port:.*#:port: ${OPENNEBULA_ONEFLOW_APIPORT}#" \
        /etc/one/oneflow-server.conf
}

configure_onegate()
{
    sed -i \
        -e "s#^:one_xmlrpc:.*#:one_xmlrpc: http://${OPENNEBULA_ONED_HOSTNAME}:${OPENNEBULA_ONED_APIPORT}/RPC2#" \
        -e "s#^:oneflow_server:.*#:oneflow_server: http://${OPENNEBULA_ONEFLOW_HOSTNAME}:${OPENNEBULA_ONEFLOW_APIPORT}#" \
        -e "s#^:host:.*#:host: 0.0.0.0#" \
        -e "s#^:port:.*#:port: ${OPENNEBULA_ONEGATE_APIPORT}#" \
        /etc/one/onegate-server.conf
}

# TODO: remove?
# The logic was moved to the mysqld-configure service
#configure_db()
#{
#    mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" \
#        -u root -p"$MYSQL_ROOT_PASSWORD" \
#        -e 'SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED;'
#}

sanity_check()
{
    if [ -z "$MYSQL_PASSWORD" ] ; then
        err "EMPTY 'MYSQL_PASSWORD' - ABORT"
        exit 1
    fi

    if [ -z "$MYSQL_ROOT_PASSWORD" ] ; then
        err "EMPTY 'MYSQL_ROOT_PASSWORD' - ABORT"
        exit 1
    fi
}

fix_docker()
{
    if ! [ -e /var/run/docker.sock ] ; then
        err "NO DOCKER SOCKET (/var/run/docker.sock): SKIP"
        return 0
    fi

    # save the gid of the docker.sock
    _docker_gid=$(stat -c %g /var/run/docker.sock)

    if getent group | grep -q '^docker:' ; then
        # we reassign the docker's GID to that of the actual docker.sock
        groupmod -g "$_docker_gid" docker
    else
        # we create docker group
        groupadd -r -g "$_docker_gid" docker
    fi

    # and we add oneadmin to the docker group
    gpasswd -a oneadmin docker
}

initialize_supervisord_conf()
{
    # respect the pre-existing config
    _DO_NOT_MODIFY_SUPERVISORD=
    if [ -f /etc/supervisord.conf ] ; then
        _DO_NOT_MODIFY_SUPERVISORD=yes
        return 0
    fi

    # otherwise create an initial stub config
    cp -a /usr/share/one/supervisor/supervisord.conf /etc/supervisord.conf
}

# arg: <service name>
add_supervised_service()
{
    # do not alter the configuration if supervisord.conf was already provided
    if [ -n "$_DO_NOT_MODIFY_SUPERVISORD" ] ; then
        msg "CUSTOM SUPERVISORD.CONF - SKIP: ${1}.ini"
        return 0
    fi

    msg "ADD SUPERVISED SERVICE: /etc/supervisord.d/${1}.ini"
    cp -a "/usr/share/one/supervisor/supervisord.d/${1}.ini" /etc/supervisord.d/
}

common_configuration()
{
    msg "CREATE ONEADMIN's TMPFILES"
    create_oneadmin_tmpfiles

    msg "SYMLINK ONEADMIN's AUTH DATA"
    link_oneadmin_auth

    msg "SYMLINK ONEADMIN's SSH DATA"
    link_oneadmin_ssh

    msg "SYMLINK ONEADMIN's DATASTORES"
    link_onedata
}

#
# frontend services
#

sshd()
{
    msg "PREPARE SSH HOST KEYS"
    restore_ssh_host_keys

    msg "REMOVE NOLOGIN FILES"
    rm -f /etc/nologin /run/nologin

    msg "CREATE ONEADMIN's SSH DIRECTORY"
    mkdir -p /oneadmin/ssh_pub_data/ssh
    chmod 0700 /oneadmin/ssh_pub_data/ssh
    chown -R "${ONEADMIN_USERNAME}:" /oneadmin/ssh_pub_data/ssh

    msg "SETUP SERVICE: SSHD"
    add_supervised_service sshd
}

mysqld()
{
    # for convenience when mysqld and oned are running together
    if [ "$OPENNEBULA_FRONTEND_SERVICE" = "all" ] ; then
        if [ -z "$MYSQL_PASSWORD" ] ; then
            msg "EMPTY 'MYSQL_PASSWORD': GENERATE RANDOM"
            MYSQL_PASSWORD=$(gen_password ${PASSWORD_LENGTH})
        fi
        if [ -z "$MYSQL_ROOT_PASSWORD" ] ; then
            msg "EMPTY 'MYSQL_ROOT_PASSWORD': GENERATE RANDOM"
            MYSQL_ROOT_PASSWORD=$(gen_password ${PASSWORD_LENGTH})
        fi
    fi

    # ensure that the mysql directory is owned by mysql user and has correct
    # permissions
    chown -R mysql:mysql /var/lib/mysql
    chmod 755 /var/lib/mysql

    msg "SETUP SERVICE: MYSQLD"
    add_supervised_service mysqld
    add_supervised_service mysqld-upgrade
    add_supervised_service mysqld-configure
}

oned()
{
    msg "SANITY CHECK"
    sanity_check

    msg "FIX DOCKER"
    fix_docker

    msg "PREPARE ONEADMIN's ONE_AUTH"
    prepare_oneadmin_data

    msg "PREPARE ONEADMIN's SSH"
    prepare_ssh

    msg "CONFIGURE DATA"
    prepare_onedata

    if is_true "${OPENNEBULA_TLS_PROXY_ENABLED}" ; then
        msg "PREPARE CERTIFICATE"
        prepare_cert
    fi

    if [ -n "${OPENNEBULA_ONED_TLSPROXY_APIPORT}" ] ; then
        msg "CONFIGURE TLS PROXY (oned)"
        configure_tlsproxy oned
    fi

    msg "CONFIGURE ONED (oned.conf)"
    configure_oned

    msg "SETUP SERVICE: OPENNEBULA ONED"
    add_supervised_service opennebula

    msg "SETUP SERVICE: SSH AGENT"
    add_supervised_service opennebula-ssh-agent
    add_supervised_service opennebula-ssh-add

    msg "SETUP SERVICE: SSH SOCKET CLEANER"
    add_supervised_service opennebula-ssh-socks-cleaner

    msg "SETUP SERVICE: OPENNEBULA SHOWBACK"
    add_supervised_service opennebula-showback
}

sunstone()
{
    if is_true "${OPENNEBULA_SUNSTONE_HTTPS_ENABLED}" ; then
        msg "PREPARE CERTIFICATE"
        prepare_cert
    fi

    msg "CONFIGURE OPENNEBULA SUNSTONE"
    configure_sunstone

    msg "SETUP SERVICE: OPENNEBULA SUNSTONE"
    if is_true "${OPENNEBULA_SUNSTONE_HTTPD}" ; then
        add_supervised_service opennebula-httpd
    else
        add_supervised_service opennebula-sunstone
    fi

    msg "SETUP SERVICE: OPENNEBULA VNC"
    add_supervised_service opennebula-novnc
}

fireedge()
{
    msg "CONFIGURE OPENNEBULA FIREEDGE"
    configure_fireedge

    msg "SETUP SERVICE: OPENNEBULA FIREEDGE"
    add_supervised_service opennebula-fireedge

    msg "SETUP SERVICE: OPENNEBULA VNC (guacd)"
    add_supervised_service opennebula-guacd
}

memcached()
{
    msg "SETUP SERVICE: MEMCACHED"
    add_supervised_service memcached
}

scheduler()
{
    msg "CONFIGURE OPENNEBULA SCHEDULER"
    configure_scheduler

    msg "SETUP SERVICE: OPENNEBULA SCHEDULER"
    add_supervised_service opennebula-scheduler
}

oneflow()
{
    msg "CONFIGURE OPENNEBULA FLOW"
    configure_oneflow

    if [ -n "${OPENNEBULA_ONEFLOW_TLSPROXY_APIPORT}" ] ; then
        msg "CONFIGURE TLS PROXY (oneflow)"
        configure_tlsproxy oneflow
    fi

    msg "SETUP SERVICE: OPENNEBULA FLOW"
    add_supervised_service opennebula-flow
}

onegate()
{
    msg "CONFIGURE OPENNEBULA GATE"
    configure_onegate

    if [ -n "${OPENNEBULA_ONEGATE_TLSPROXY_APIPORT}" ] ; then
        msg "CONFIGURE TLS PROXY (onegate)"
        configure_tlsproxy onegate
    fi

    msg "SETUP SERVICE: OPENNEBULA GATE"
    add_supervised_service opennebula-gate
}

onehem()
{
    # TODO: does it make sense to run separately from oned? (can be even?)
    #msg "CONFIGURE OPENNEBULA HEM"
    #configure_onehem

    msg "SETUP SERVICE: OPENNEBULA HEM"
    add_supervised_service opennebula-hem
}

tlsproxy()
{
    # prepare TLS proxy service
    if is_true "${OPENNEBULA_TLS_PROXY_ENABLED}" ; then
        msg "SETUP SERVICE: STUNNEL"
        add_supervised_service stunnel
    fi
}

###############################################################################
# start service
#

# run prestart hook if any
if [ -f /prestart-hook.sh ] && [ -x /prestart-hook.sh ] ; then
    /prestart-hook.sh
fi

msg "BEGIN BOOTSTRAP (${0}): ${OPENNEBULA_FRONTEND_SERVICE}"

# shared steps for all containers
common_configuration
initialize_supervisord_conf

# this is mandatory for logrotate and it also functions as a more meaningful
# replacement for the infinite loop service
msg "SETUP SERVICE: CRON"
add_supervised_service crond

case "${OPENNEBULA_FRONTEND_SERVICE}" in
    none)
        msg "MAINTENANCE MODE - NOTHING TO DO"
        # supervisord needs at least one program section...should not be needed
        # thanks to the crond but just in case...
        msg "SETUP SERVICE: INFINITE LOOP"
        add_supervised_service infinite-loop
        ;;
    all)
        msg "CONFIGURE FRONTEND SERVICE: ALL"
        # this will fix some issues:
        echo 127.0.0.1 "$OPENNEBULA_FRONTEND_SSH_HOSTNAME" \
            >> /etc/hosts
        sshd
        mysqld
        oned
        tlsproxy
        scheduler
        oneflow
        onegate
        onehem
        sunstone
        memcached
        # TODO: return to this when fireedge is finished
        #fireedge
        ;;
    oned)
        msg "CONFIGURE FRONTEND SERVICE: ONED"
        oned
        onehem
        tlsproxy
        ;;
    sshd)
        msg "CONFIGURE FRONTEND SERVICE: SSHD"
        sshd
        switch_to_pub_ssh_data
        ;;
    mysqld)
        msg "CONFIGURE FRONTEND SERVICE: MYSQLD"
        mysqld
        ;;
    memcached)
        msg "CONFIGURE FRONTEND SERVICE: MEMCACHED"
        memcached
        ;;
    sunstone)
        msg "CONFIGURE FRONTEND SERVICE: SUNSTONE"
        sunstone
        ;;
    fireedge)
        msg "CONFIGURE FRONTEND SERVICE: FIREEDGE"
        fireedge
        ;;
    scheduler)
        msg "CONFIGURE FRONTEND SERVICE: SCHEDULER"
        scheduler
        ;;
    oneflow)
        msg "CONFIGURE FRONTEND SERVICE: ONEFLOW"
        oneflow
        tlsproxy
        ;;
    onegate)
        msg "CONFIGURE FRONTEND SERVICE: ONEGATE"
        onegate
        tlsproxy
        ;;
    *)
        err "UNKNOWN FRONTEND SERVICE: ${OPENNEBULA_FRONTEND_SERVICE}"
        exit 1
        ;;
esac

msg "BOOTSTRAP FINISHED"

msg "EXEC SUPERVISORD"
exec /usr/bin/supervisord -n -c /etc/supervisord.conf

