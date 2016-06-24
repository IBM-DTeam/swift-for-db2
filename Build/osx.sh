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

# Install dependencies
brew install wget unixodbc

# Install the IBM DB2 CLI
wget https://github.com/IBM-DTeam/swift-for-db2-cli/archive/master.zip && unzip master.zip && cd swift-for-db2-cli-master && sudo ./cli.sh && . env.sh && cd .. && rm -f master.zip && rm -rf swift-for-db2-cli-master

# Get the needed Swift snapshot
export SWIFT_VERSION=swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a
wget https://swift.org/builds/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a/swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a-osx.pkg
sudo installer -pkg swift-DEVELOPMENT-SNAPSHOT-2016-05-09-a-osx.pkg -target /
export TOOLCHAINS=swift

# DB2 database used for testing
export DB2_CONN_STRING="DRIVER={DB2};DATABASE=BLUDB;UID=dash6435;PWD=0NKUFZxcskVZ;HOSTNAME=dashdb-entry-yp-dal09-09.services.dal.bluemix.net;PORT=50000"

# Build the project and test it
git clone -b ${TRAVIS_BRANCH} https://github.com/IBM-DTeam/swift-for-db2.git && cd swift-for-db2 && git checkout ${TRAVIS_COMMIT} && swift build -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib && swift test
