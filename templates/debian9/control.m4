Source: opennebula
Section: utils
Priority: extra
Maintainer: _CONTACT_
Uploaders: Damien Raude-Morvan <drazzib@debian.org>,
           Soren Hansen <soren@ubuntu.com>,
           Jaime Melis <jmelis@opennebula.org>
Build-Depends: bash-completion,
               bison,
               debhelper (>= 7.0.50~),
               dh-systemd (>= 1.5),
               default-jdk,
               flex,
               javahelper (>= 0.32),
               libmysql++-dev,
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
               scons
Standards-Version: 3.9.3
Homepage: http://opennebula.org/
Vcs-Git: git://git.debian.org/pkg-opennebula/opennebula.git
Vcs-Browser: http://git.debian.org/?p=pkg-opennebula/opennebula.git

Package: opennebula
Architecture: any
Depends: apg,
         genisoimage,
         opennebula-common (= ${source:Version}),
         opennebula-tools (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         wget,
         curl,
         rsync,
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
          opennebula-common (<< 5.5.80)
Breaks:  ruby-opennebula (<< 5.5.80),
         opennebula-sunstone (<< 5.0.2),
         opennebula-flow (<< 5.0.2),
         opennebula-gate (<< 5.0.2),
         opennebula-common (<< 5.5.80)
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
Depends: adduser, openssh-client, ${misc:Depends}
Recommends: lvm2, sudo (>= 1.7.2p1)
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

Package: opennebula-node
Architecture: all
Depends: adduser,
         libvirt-daemon-system,
         qemu-kvm | pve-qemu-kvm,
         opennebula-common (= ${source:Version}),
         ruby,
         vlan,
         ipset,
         pciutils,
         rsync,
         cron,
         augeas-tools,
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
         _RUBYGEMS_REQ_
         libffi6,
         libsqlite3-0,
         libmariadbclient18,
         libaugeas0,
         ${misc:Depends}
Conflicts: opennebula (<< ${source:Version})
Description: Metapackage to install all Ruby gem dependencies
')

Package: opennebula-tools
Architecture: all
Depends: opennebula-common (= ${source:Version}),
         ruby-opennebula (= ${source:Version}),
         ifdef(`_WITH_RUBYGEMS_',`opennebula-rubygems (= ${source:Version}),')dnl
         less,
         ${misc:Depends},
         ${ruby:Depends}
Breaks: opennebula (<< 5.5.90)
Replaces: opennebula (<< 5.5.90)
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
