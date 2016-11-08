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
# Docker OS X container (Travis CI) and tests it.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Install dependencies
brew install wget unixodbc

# Install the Swift SDK for DB2 CLI
wget https://github.com/IBM-DTeam/swift-for-db2-cli/archive/new.zip && unzip new.zip && cd swift-for-db2-cli-new && sudo setup/intall.sh && . setup/env.sh && make install && cd .. && rm -f new.zip && rm -rf swift-for-db2-cli-new

# Get the needed Swift snapshot
export SWIFT_VERSION=swift-3.0-RELEASE-osx
wget https://swift.org/builds/swift-3.0-release/xcode/swift-3.0-RELEASE/swift-3.0-RELEASE-osx.pkg
sudo installer -pkg swift-3.0-RELEASE-osx.pkg -target /
export TOOLCHAINS=swift

# DB2 database used for testing
export DB2_CONN_STRING="DRIVER={DB2};DATABASE=BLUDB;UID=dash6435;PWD=0NKUFZxcskVZ;HOSTNAME=dashdb-entry-yp-dal09-09.services.dal.bluemix.net;PORT=50000"

# Build the project and test it
cd ${TRAVIS_BUILD_DIR} && swift build
#&& swift test -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib
