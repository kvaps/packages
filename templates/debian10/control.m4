define(`P_EDITION',       ifdef(`_WITH_ENTERPRISE_', `Enterprise Edition', `Community Edition'))
define(`P_EDITION_SHORT', ifdef(`_WITH_ENTERPRISE_', `ee', `ce'))

Source: opennebula
Section: utils
Priority: extra
Maintainer: _CONTACT_
Build-Depends: bash-completion,
               bison,
               debhelper (>= 7.0.50~),
               dh-systemd (>= 1.5),
               default-jdk,
               flex,
               javahelper (>= 0.32),
               default-libmysqlclient-dev,
               postgresql-server-dev-all,
               libsqlite3-dev,
               libssl-dev,
               libws-commons-util-java,
               libxml2-dev,
               libxmlrpc-c++8-dev,
               libxmlrpc3-client-java,
               libxmlrpc3-common-java,
               libxslt1-dev,
               libsystemd-dev,
               libvncserver-dev,
               ruby,
               python-setuptools,
               python-wheel,
               python3-setuptools,
               scons,
# Rubygems, TODO: reduce
               ruby-dev,
               make,
               gcc,
               libsqlite3-dev,
               libcurl4-openssl-dev,
               rake,
               libxml2-dev,
               libxslt1-dev,
               patch,
               g++,
               build-essential,
               libssl-dev,
               libaugeas-dev,
               postgresql-server-dev-all,
               default-libmysqlclient-dev | libmysqlclient-dev
Standards-Version: 3.9.3
Homepage: http://opennebula.org/
Vcs-Git: git://git.debian.org/pkg-opennebula/opennebula.git
Vcs-Browser: http://git.debian.org/?p=pkg-opennebula/opennebula.git

Package: opennebula
Architecture: any
Pre-Depends: opennebula-common-onescape (= ${source:Version})
Depends: apg,
         genisoimage,
         opennebula-common (= ${source:Version}),
         opennebula-tools (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_ENTERPRISE_',`opennebula-migration (= ${source:Version}),')dnl
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         wget,
         curl,
         rsync,
         sqlite3,
         qemu-utils,
         iputils-arping,
         libzmq5,
# Devel package brings libzmq.so symlink required by ffi-rzmq-core gem
         libzmq3-dev,
         ${misc:Depends},
         ${shlibs:Depends}
Replaces: ruby-opennebula (<< 5.5.80),
          opennebula-sunstone (<< 5.0.2),
          opennebula-flow (<< 5.0.2),
          opennebula-gate (<< 5.0.2),
          opennebula-common (<< 5.5.80),
          opennebula-addon-markets (<< 5.10.2)
Breaks:  ruby-opennebula (<< 5.5.80),
         opennebula-sunstone (<< 5.0.2),
         opennebula-flow (<< 5.0.2),
         opennebula-gate (<< 5.0.2),
         opennebula-common (<< 5.5.80),
         opennebula-addon-markets (<< 5.10.2)
Suggests: mysql-server
Description: OpenNebula Server and Scheduler (P_EDITION)

Package: opennebula-dbgsym
Architecture: any
Depends: opennebula (= ${source:Version}),
         ${misc:Depends}
Description: Debug symbols for package opennebula (P_EDITION)

Package: opennebula-sunstone
Architecture: all
Pre-Depends: opennebula-common-onescape (= ${source:Version})
Depends: opennebula-common (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         opennebula-tools (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         python,
         python-numpy,
         ${misc:Depends}
Conflicts: opennebula (<< ${source:Version})
Description: OpenNebula web interface Sunstone (P_EDITION)
 Browser based UI for OpenNebula cloud management and usage.

Package: opennebula-gate
Architecture: all
Pre-Depends: opennebula-common-onescape (= ${source:Version})
Depends: opennebula-common (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         ${misc:Depends}
Conflicts: opennebula (<< ${source:Version})
Description: OpenNebula Gate server (P_EDITION)
 Server for information exchange between Virtual Machines and OpenNebula.

Package: opennebula-flow
Architecture: all
Pre-Depends: opennebula-common-onescape (= ${source:Version})
Depends: opennebula-common (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         curl,
         ${misc:Depends}
Conflicts: opennebula (<< ${source:Version})
Description:  OpenNebula Flow server (P_EDITION)
 Server for multi-VM orchestration.

Package: opennebula-common
Architecture: all
Pre-Depends: opennebula-common-onescape (= ${source:Version})
Depends: adduser,
         openssh-client,
         ${misc:Depends}
Recommends: lvm2, sudo (>= 1.7.2p1)
Replaces: opennebula (<< 5.11.90),
          opennebula-node (<< 5.11.90),
          opennebula-node-firecracker (<< 5.11.90)
Breaks: opennebula (<< 5.11.90),
        opennebula-node (<< 5.11.90),
        opennebula-node-firecracker (<< 5.11.90)
Description: Common OpenNebula package shared by various components (P_EDITION)

Package: opennebula-common-onescape
Architecture: all
Depends: ${misc:Depends}
Description: Helpers for OpenNebula OneScape project (P_EDITION)

Package: opennebula-node
Architecture: all
Depends: adduser,
         libvirt-daemon-system,
         qemu-kvm | pve-qemu-kvm,
         qemu-utils,
         opennebula-common (= ${source:Version}),
         ruby,
         vlan,
         ipset,
         pciutils,
         rsync,
         cron,
         augeas-tools,
         ruby-sqlite3,
         ${misc:Depends}
Recommends: openssh-server | ssh-server
Description: Services for OpenNebula KVM node (P_EDITION)

Package: opennebula-node-lxd
Architecture: any
Depends: opennebula-common (= ${source:Version}),
         kpartx,
         libvncserver1,
         e2fsprogs,
         xfsprogs,
         qemu-utils,
         adduser,
         ruby,
         vlan,
         ipset,
         pciutils,
         rsync,
         cron,
         ruby-sqlite3,
         ${misc:Depends}
Pre-Depends: snapd
Suggests: rbd-nbd
Replaces: lxd,
          lxd-client,
          opennebula-lxd-snap
Conflicts: lxd,
           lxd-client,
           opennebula-lxd-snap
Description: Services for OpenNebula LXD node (P_EDITION)

Package: opennebula-node-firecracker
Architecture: any
Depends: adduser,
         opennebula-common (= ${source:Version}),
         ruby,
         vlan,
         ipset,
         pciutils,
         rsync,
         cron,
         augeas-tools,
         ruby-sqlite3,
         libarchive-tools,
         screen,
         libvncserver1,
         e2fsprogs,
         lsof,
         qemu-utils,
         ${misc:Depends}
Description: Services for OpenNebula Firecracker node (P_EDITION)

Package: python-pyone
Section: python
Architecture: all
Depends: python,
         python-pip,
         ${misc:Depends},
         ${python:Depends}
Description: Python 2 bindings for OpenNebula Cloud API, OCA (P_EDITION)

Package: python3-pyone
Section: python
Architecture: all
Depends: python3,
         python3-pip,
         ${misc:Depends},
         ${python:Depends}
Description: Python 3 bindings for OpenNebula Cloud API, OCA (P_EDITION)

Package: ruby-opennebula
Section: ruby
Architecture: all
Depends: ruby,
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         ${misc:Depends},
         ${ruby:Depends}
Breaks: opennebula-gate (<< 4.90.5), opennebula-sunstone (<< 4.90.5)
Replaces: opennebula-gate (<< 4.90.5), opennebula-sunstone (<< 4.90.5)
Description: OpenNebula Ruby libraries (P_EDITION)

ifdef(`_WITH_RUBYGEMS_',`
Package: opennebula-rubygems
Architecture: all
Depends: ruby,
         ${misc:depends},
         ${shlibs:Depends}
Conflicts: opennebula (<< ${source:Version}),
           opennebula-rubygem-activesupport,
           opennebula-rubygem-addressable,
           opennebula-rubygem-amazon-ec2,
           opennebula-rubygem-augeas,
           opennebula-rubygem-aws-eventstream,
           opennebula-rubygem-aws-sdk,
           opennebula-rubygem-aws-sdk-core,
           opennebula-rubygem-aws-sdk-resources,
           opennebula-rubygem-aws-sigv4,
           opennebula-rubygem-azure,
           opennebula-rubygem-azure-core,
           opennebula-rubygem-builder,
           opennebula-rubygem-chunky-png,
           opennebula-rubygem-concurrent-ruby,
           opennebula-rubygem-configparser,
           opennebula-rubygem-curb,
           opennebula-rubygem-daemons,
           opennebula-rubygem-dalli,
           opennebula-rubygem-eventmachine,
           opennebula-rubygem-faraday,
           opennebula-rubygem-faraday-middleware,
           opennebula-rubygem-ffi,
           opennebula-rubygem-ffi-rzmq,
           opennebula-rubygem-ffi-rzmq-core,
           opennebula-rubygem-hashie,
           opennebula-rubygem-highline,
           opennebula-rubygem-i18n,
           opennebula-rubygem-inflection,
           opennebula-rubygem-ipaddress,
           opennebula-rubygem-jmespath,
           opennebula-rubygem-memcache-client,
           opennebula-rubygem-mime-types,
           opennebula-rubygem-mime-types-data,
           opennebula-rubygem-mini-portile2,
           opennebula-rubygem-minitest,
           opennebula-rubygem-multipart-post,
           opennebula-rubygem-mustermann,
           opennebula-rubygem-mysql2,
           opennebula-rubygem-net-ldap,
           opennebula-rubygem-nokogiri,
           opennebula-rubygem-ox,
           opennebula-rubygem-parse-cron,
           opennebula-rubygem-polyglot,
           opennebula-rubygem-public-suffix,
           opennebula-rubygem-rack,
           opennebula-rubygem-rack-protection,
           opennebula-rubygem-rotp,
           opennebula-rubygem-rqrcode,
           opennebula-rubygem-rqrcode-core,
           opennebula-rubygem-scrub-rb,
           opennebula-rubygem-sequel,
           opennebula-rubygem-sinatra,
           opennebula-rubygem-sqlite3,
           opennebula-rubygem-systemu,
           opennebula-rubygem-thin,
           opennebula-rubygem-thor,
           opennebula-rubygem-thread-safe,
           opennebula-rubygem-tilt,
           opennebula-rubygem-treetop,
           opennebula-rubygem-trollop,
           opennebula-rubygem-tzinfo,
           opennebula-rubygem-uuidtools,
           opennebula-rubygem-xmlrpc,
           opennebula-rubygem-xml-simple,
           opennebula-rubygem-zendesk-api
Description: Ruby dependencies for OpenNebula (P_EDITION)
')

Package: opennebula-tools
Architecture: all
Pre-Depends: opennebula-common-onescape (= ${source:Version})
Depends: opennebula-common (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         less,
         ${misc:Depends},
         ${ruby:Depends}
Recommends: gnuplot-nox
Breaks: opennebula (<< 5.5.90),
        opennebula-addon-tools (<< 5.10.2)
Replaces: opennebula (<< 5.5.90),
          opennebula-addon-tools (<< 5.10.2)
Description: OpenNebula command line tools (P_EDITION)

Package: libopennebula-java
Section: java
Architecture: all
Depends: ${java:Depends}, ${misc:Depends},
         libws-commons-util-java,
         libxmlrpc3-client-java,
         libxmlrpc3-common-java
Description: Java bindings for OpenNebula Cloud API, OCA (P_EDITION)

Package: libopennebula-java-doc
Section: doc
Architecture: all
Depends: ${misc:Depends}
Recommends: ${java:Recommends}
Description: Documentation for Java bindings for OpenNebula Cloud API, OCA (P_EDITION)

Package: opennebula-provision
Architecture: all
Pre-Depends: opennebula-common-onescape (= ${source:Version})
Depends: opennebula (= ${source:Version}),
         opennebula-common (= ${source:Version}),
         opennebula-tools (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         ${misc:Depends}
Description: OpenNebula infrastructure provisioning (P_EDITION)

ifdef(`_WITH_DOCKER_MACHINE_',`
Package: docker-machine-opennebula
Architecture: any
Description: OpenNebula driver for Docker Machine (P_EDITION)
')

ifdef(`_WITH_ADDON_TOOLS_',`
Package: opennebula-addon-tools
Architecture: all
Depends: opennebula-common (= ${source:Version}),
         opennebula (= ${source:Version}),
         ${misc:Depends}
Conflicts: opennebula-cli-extensions
Description: The CLI extension package install new subcomands that extend (P_EDITION)
 the functionality of the standard OpenNebula CLI, to enable and/or
 simplify common workflows for production deployments.
 .
 This package is distributed under the
 OpenNebula Systems Commercial Open-Source Software License
 https://raw.githubusercontent.com/OpenNebula/one/master/LICENSE.addons
')

ifdef(`_WITH_ADDON_MARKETS_',`
Package: opennebula-addon-markets
Architecture: all
Depends: opennebula-common (= ${source:Version}),
         opennebula (= ${source:Version}),
         ${misc:Depends}
Description: OpenNebula Enterprise Markets Addon will link turnkeylinux.org (P_EDITION)
 as a marketplace allowing users to easily interact and download
 existing appliances from Turnkey.
 .
 This package is distributed under the
 OpenNebula Systems Commercial Open-Source Software License
 https://raw.githubusercontent.com/OpenNebula/one/master/LICENSE.addons
')

ifdef(`_WITH_ENTERPRISE_',`
Package: opennebula-migration
Architecture: all
Depends: opennebula (= ${source:Version}),
         ${misc:Depends}
Replaces: opennebula-migration-community
Conflicts: opennebula-migration-community
Description: Migration tools for OpenNebula Enterprise Edition
 .
 IMPORTANT: This package is distributed under "OpenNebula Software License".
 See /usr/share/doc/one/LICENSE.onsla.gz provided by opennebula-common package.

Package: opennebula-migration-community
Architecture: all
Depends: opennebula (>= 5.12), opennebula (<< 5.13),
         ${misc:Depends}
Replaces: opennebula-migration
Conflicts: opennebula-migration
Description: Migration tools for OpenNebula Community Edition
 .
 IMPORTANT: This package is distributed under the "OpenNebula Software License
 for Non-Commercial Use". See /usr/share/doc/one/LICENSE.onsla-nc.gz provided
 by opennebula-common package.
')
