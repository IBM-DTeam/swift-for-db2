#!/bin/bash

##
# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

# This script builds the corresponding Swift IBM DB Package in a
# Docker ubuntu container (Travis CI) and tests it.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Ubuntu 15.10
docker pull ubuntu:wily

# Install dependencies
update="apt-get update"
install_primary="apt-get install -y clang unixodbc-dev unzip wget tar git sudo"

# Install the IBM DB2 CLI
install_cli="wget https://github.com/IBM-DTeam/swift-ibm-db-cli/archive/master.zip && unzip master.zip && cd swift-ibm-db-cli-master && sudo ./cli.sh && . env.sh && cd .. && rm -f master.zip && rm -rf swift-ibm-db-cli-master"

# Get the needed Swift snapshot
get_swift="wget https://swift.org/builds/development/ubuntu1510/swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a/swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a-ubuntu15.10.tar.gz"
open_swift="tar -xvzf swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a-ubuntu15.10.tar.gz"
mkdir_swift="mkdir -p /home/root/swift"
cp_swift="cp -r swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a-ubuntu15.10/* /home/root/swift/"
export_path="export PATH=/home/root/swift/usr/bin:$PATH"

# DB2 database used for testing
export_db="export DB2_CONN_STRING=\"DRIVER={DB2};DATABASE=BLUDB;UID=dash6435;PWD=0NKUFZxcskVZ;HOSTNAME=dashdb-entry-yp-dal09-09.services.dal.bluemix.net;PORT=50000\""

# Dependencies for the dispatch library
install_secondary="apt-get install -y autoconf libtool pkg-config systemtap-sdt-dev libblocksruntime-dev libkqueue-dev libbsd-dev"
ldispatch="git clone -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git && cd swift-corelibs-libdispatch && git submodule init && git submodule update && sh ./autogen.sh && ./configure --with-swift-toolchain=/home/root/swift/usr --prefix=/home/root/swift/usr && make && make install"

# Build the project and test it
build_and_test="git clone -b ${TRAVIS_BRANCH} https://github.com/IBM-DTeam/swift-ibm-db.git && cd swift-ibm-db && git checkout ${TRAVIS_COMMIT} && swift build -Xcc -fblocks -Xlinker -ldispatch && swift test"

docker run -i -t ubuntu:wily /bin/bash -c "${update} && ${install_primary} && ${install_cli} && ${get_swift} && ${open_swift} && ${mkdir_swift} && ${cp_swift} && ${export_path} && ${export_db} && ${install_secondary} && ${ldispatch} && ${build_and_test}"
