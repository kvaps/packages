# OpenNebula Packaging

This repository contains scripts for building the
[OpenNebula](https://github.com/OpenNebula/one). The build process
is divided into following steps:

1. install build requirements
2. get or generate source code archive
3. build packages

**IMPORTANT**: Always use the correct branch with the scripts corresponding
to the OpenNebula you are going to build! For example, to build development
OpenNebula, use the `master` branch. To build the latest yet unreleased
OpenNebula 5.8.x, use the `one-5.8` branch. Or, to build OpenNebula 5.8.2
release, use the repository state referenced by the tag `release-5.8.2`.

## Build Requirements

You need to have following dependencies installed on your system to be able to
build `rpm` and `deb` packages. `rpm` packages can be built on RHEL or CentOS,
`deb` packages can be built on Debian on Ubuntu.

Install deps. to build `rpm` packages on CentOS 7:

```
yum install -y wget m4 mock
```

Install deps. to build `deb` packages on Debian or Ubuntu:

```
apt-get install -y wget m4 rename pbuilder ubuntu-dev-tools
```

## Source Archive

Build scripts require the source archive containing the OpenNebula source
codes, generated manual pages, and all JavaScript dependencies. The archive is available for each public
release or can be created from the source code taken from the
[VCS](https://github.com/OpenNebula/one).

### Public Release Archive

Inside the release download directory, you can find the source archive.
The URL template based on the desired OpenNebula version is
`https://downloads.opennebula.org/packages/opennebula-${RELEASE}/opennebula-${RELEASE}.tar.gz`

For example, the release 5.4.0 has source archive here:

* https://downloads.opennebula.org/packages/opennebula-5.4.0/opennebula-5.4.0.tar.gz

### Create Archive

If you take the source code from the [VCS](https://github.com/OpenNebula/one),
you have to install following dependencies on your own to be able to generate
enriched archive for the following build of packages:

- `npm`
- Ruby gems (https://rubygems.org/):
    - `ronn`
    - `sequel`
    - `nokogiri`
    - `amazon-ec2`
    - `builder`
    - `ipaddress`
    - `highline`

We use the **CentOS 7** instance to generate single archive for all platforms.

Steps required to get sources for the OpenNebula X.Y.Z (change the placeholders with particular version) and create the archive.

```
git clone https://github.com/OpenNebula/one opennebula-X.Y.Z
cd opennebula-X.Y.Z
git checkout tags/release-X.Y.Z

# manual pages
cd share/man
./build.sh
cd ../../

# sunstone
cd  src/sunstone/public
./build.sh -d
export PATH=$PATH:$PWD/node_modules/.bin
./build.sh
rm -rf node_modules/
cd ../../../../

tar -czf opennebula-X.Y.Z.tar.gz opennebula-X.Y.Z/
```

Note: Archive name must have format `${NAME}-${RELEASE}.tar.gz`  and
main directory inside must be `${NAME}-${RELEASE}`.

## Build

There are various build scripts available, one for each supported platform.
Scripts require URL or filesystem path with the OpenNebula source archive
from the previous section and optional paths of source archives
for the optional components.

CentOS, Debian, and Ubuntu builds leverage tools (`mock` and `pbuilder`)
to build binary packages in the chroot in an environment similar to the
target platform. It's not necessary to build on the very same system until you
have the required tools available and working. E.g., on Ubuntu 18.04 you
can build packages for all supported Ubuntu and Debian.

The Build of the additional components needs to be enabled by the `BUILD_COMPONENTS`
environment variable. Optional builds are specified as a whitespace separeted
list of names. Most of the optional components are private only, there
are only a few which makes sense for public builds.

| Build Component     | Description                            |
|---------------------|----------------------------------------|
| rubygems            | Package all Ruby gems                  |
| docker\_machine     | Create Docker Machine package          |

Examples:

```
cd packages/
./centos7.sh ../opennebula-5.10.0.tar.gz
./debian9.sh ../opennebula-5.10.0.tar.gz
./ubuntu1610.sh https://downloads.opennebula.org/packages/opennebula-5.10.0/opennebula-5.10.0.tar.gz
BUILD_COMPONENTS='rubygems docker_machine' ./centos7.sh http://downloads.opennebula.org/packages/opennebula-5.10.0/opennebula-5.10.0.tar.gz http://downloads.opennebula.org/packages/opennebula-5.10.0/opennebula-docker-machine-5.10.0.tar.gz
```

## Contact

OpenNebula web page: http://opennebula.org

Development and issue tracking: http://dev.opennebula.org

Support: http://opennebula.org/support:support

## License

Copyright 2002-2019, OpenNebula Project, OpenNebula Systems (formerly C12G Labs)

Licensed under the Apache License, Version 2.0 (the "License"); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
