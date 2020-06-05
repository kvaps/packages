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
               libmysql++-dev,
               postgresql-server-dev-all,
               libsqlite3-dev,
               libssl-dev,
               libws-commons-util-java,
               libxml2-dev,
               libxmlrpc3-client-java,
               libxmlrpc3-common-java,
               libxslt1-dev,
               libcurl4-openssl-dev,
               libsystemd-dev,
               libvncserver-dev,
               python-setuptools,
               python-wheel,
               python3-setuptools,
               ruby,
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
Depends: apg,
         genisoimage,
         opennebula-common (= ${source:Version}),
         opennebula-common-onescape (= ${source:Version}),
         opennebula-tools (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_ENTERPRISE_',`opennebula-migration (= ${source:Version}),')dnl
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         wget,
         curl,
         rsync,
         sqlite3,
         qemu-utils,
         libcurl3,
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
Description: controller which executes the OpenNebula cluster services
 OpenNebula is an open source virtual infrastructure engine that enables the
 dynamic deployment and re-placement of virtual machines on a pool of physical
 resources.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package contains OpenNebula Controller which manage all nodes in the
 cloud.

Package: opennebula-dbgsym
Architecture: any
Depends: opennebula (= ${source:Version}),
         ${misc:Depends}
Description: debug symbols for opennebula

Package: opennebula-sunstone
Architecture: all
Depends: opennebula-common (= ${source:Version}),
         opennebula-common-onescape (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         opennebula-tools (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         python,
         python-numpy,
         ${misc:Depends}
Conflicts: opennebula (<< ${source:Version})
Description: web interface to which executes the OpenNebula cluster services
 OpenNebula is an open source virtual infrastructure engine that enables the
 dynamic deployment and re-placement of virtual machines on a pool of physical
 resources.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 OpenNebula Sunstone is the new OpenNebula Cloud Operations Center,
 a GUI intended for users and admins, that will simplify the typical management
 operations in private and hybrid cloud infrastructures. You will be able to
 manage your virtual resources in a similar way as you do with the
 CLI.

Package: opennebula-gate
Architecture: all
Depends: opennebula-common (= ${source:Version}),
         opennebula-common-onescape (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         ${misc:Depends}
Conflicts: opennebula (<< ${source:Version})
Description: send information to OpenNebula from the Virtual Machines.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package provides the server part to enable communication between the
 Virtual Machines and OpenNebula

Package: opennebula-flow
Architecture: all
Depends: opennebula-common (= ${source:Version}),
         opennebula-common-onescape (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         curl,
         ${misc:Depends}
Conflicts: opennebula (<< ${source:Version})
Description: Manage services.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package provides the server that allows service management.


Package: opennebula-common
Architecture: all
Depends: opennebula-common-onescape (= ${source:Version}),
         adduser,
         openssh-client,
         ${misc:Depends}
Recommends: lvm2, sudo (>= 1.7.2p1)
Replaces: opennebula (<< 5.11.85),
          opennebula-node (<< 5.11.85),
          opennebula-node-firecracker (<< 5.11.85)
Breaks: opennebula (<< 5.11.85),
        opennebula-node (<< 5.11.85),
        opennebula-node-firecracker (<< 5.11.85)
Description: empty package to create OpenNebula users and directories
 OpenNebula is an open source virtual infrastructure engine that enables the
 dynamic deployment and re-placement of virtual machines on a pool of physical
 resources.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package sets up the basic directory structure and users needed to run
 an OpenNebula cloud.

Package: opennebula-common-onescape
Architecture: all
Depends: ${misc:Depends}
Description: Helpers for OpenNebula OneScape project

Package: opennebula-node
Architecture: all
Depends: adduser,
         libvirt-bin,
         qemu-kvm | pve-qemu-kvm,
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
Description: empty package to prepare a machine as OpenNebula Node
 OpenNebula is an open source virtual infrastructure engine that enables the
 dynamic deployment and re-placement of virtual machines on a pool of physical
 resources.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package prepares the machine for being a node in an OpenNebula
 cloud.

Package: opennebula-lxd-snap
Architecture: any
Pre-Depends: snapd
Replaces: lxd,
          lxd-client
Conflicts: lxd,
           lxd-client
Description: LXD installed as a snap

Package: opennebula-node-lxd
Architecture: any
Depends: opennebula-common (= ${source:Version}),
         kpartx,
         libvncserver1,
         e2fsprogs,
         xfsprogs,
         lxd (>= 3.0.0) | opennebula-lxd-snap (= ${source:Version}),
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
Suggests: rbd-nbd
Replaces: lxd (<< 3.0.0),
          lxd-client (<< 3.0.0)
Conflicts: lxd (<< 3.0.0),
           lxd-client (<< 3.0.0)
Description: sets up an OpenNebula LXD virtualization node

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
         bsdtar,
         screen,
         libvncserver1,
         e2fsprogs,
         qemu-utils,
         ${misc:Depends}
Description: sets up an OpenNebula Firecracker virtualization node

Package: python-pyone
Section: python
Architecture: all
Depends: python,
         python-pip,
         ${misc:Depends},
         ${python:Depends}
Description: Python bindings for OpenNebula Cloud API (OCA)

Package: python3-pyone
Section: python
Architecture: all
Depends: python3,
         python3-pip,
         ${misc:Depends},
         ${python:Depends}
Description: Python3 bindings for OpenNebula Cloud API (OCA)

Package: ruby-opennebula
Section: ruby
Architecture: all
Depends: ruby,
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         ${misc:Depends},
         ${ruby:Depends}
Breaks: opennebula-gate (<< 4.90.5), opennebula-sunstone (<< 4.90.5)
Replaces: opennebula-gate (<< 4.90.5), opennebula-sunstone (<< 4.90.5)
Description: Ruby bindings for OpenNebula Cloud API (OCA)
 OpenNebula is an open source virtual infrastructure engine that enables the
 dynamic deployment and re-placement of virtual machines on a pool of physical
 resources.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package provides the OpenNebula Cloud API (OCA) Ruby bindings.

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
Description: Complete Ruby gems dependencies for OpenNebula
')

Package: opennebula-tools
Architecture: all
Depends: opennebula-common (= ${source:Version}),
         opennebula-common-onescape (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         less,
         ${misc:Depends},
         ${ruby:Depends}
Breaks: opennebula (<< 5.5.90),
        opennebula-addon-tools (<< 5.10.2)
Replaces: opennebula (<< 5.5.90),
          opennebula-addon-tools (<< 5.10.2)
Description: Command-line tools for OpenNebula Cloud
 OpenNebula is an open source virtual infrastructure engine that enables the
 dynamic deployment and re-placement of virtual machines on a pool of physical
 resources.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package provides the OpenNebula CLI.

Package: libopennebula-java
Section: java
Architecture: all
Depends: ${java:Depends}, ${misc:Depends},
         libws-commons-util-java,
         libxmlrpc3-client-java,
         libxmlrpc3-common-java
Description: Java bindings for OpenNebula Cloud API (OCA)
 OpenNebula is an open source virtual infrastructure engine that enables the
 dynamic deployment and re-placement of virtual machines on a pool of physical
 resources.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package provides the OpenNebula Cloud API (OCA) Java bindings.

Package: libopennebula-java-doc
Section: doc
Architecture: all
Depends: ${misc:Depends}
Recommends: ${java:Recommends}
Description: Java bindings for OpenNebula Cloud API (OCA) - documentation
 OpenNebula is an open source virtual infrastructure engine that enables the
 dynamic deployment and re-placement of virtual machines on a pool of physical
 resources.
 .
 ONE (OpenNebula) extends the benefits of virtualization platforms from a
 single physical resource to a pool of resources, decoupling the server not
 only from the physical infrastructure but also from the physical location.
 .
 This package provides the documentation (Javadoc API) and examples for
 OpenNebula Cloud API (OCA) Java bindings.

Package: opennebula-provision
Architecture: all
Depends: opennebula (= ${source:Version}),
         opennebula-common (= ${source:Version}),
         opennebula-tools (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         ${misc:Depends}
Description: OpenNebula provisioning tool

ifdef(`_WITH_DOCKER_MACHINE_',`
Package: docker-machine-opennebula
Architecture: any
Description: OpenNebula driver for Docker Machine
')

ifdef(`_WITH_ADDON_TOOLS_',`
Package: opennebula-addon-tools
Architecture: all
Depends: opennebula-common (= ${source:Version}),
         opennebula (= ${source:Version}),
         ${misc:Depends}
Conflicts: opennebula-cli-extensions
Description: The CLI extension package install new subcomands that extend
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
Description: OpenNebula Enterprise Markets Addon will link turnkeylinux.org
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
Description: OpenNebula migrators
 .
 This package is distributed under the
 OpenNebula Systems Commercial Open-Source Software License
 https://raw.githubusercontent.com/OpenNebula/one/master/LICENSE.addons

Package: opennebula-migration-community
Architecture: all
Depends: opennebula (>= 5.12), opennebula (<< 5.13),
         ${misc:Depends}
Replaces: opennebula-migration
Conflicts: opennebula-migration
Description: OpenNebula migrators from previous version
 .
 This package is distributed under the
 OpenNebula Systems Commercial Open-Source Software License
 https://raw.githubusercontent.com/OpenNebula/one/master/LICENSE.addons
')
