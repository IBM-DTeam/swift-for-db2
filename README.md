![swift-for-db2](https://ibm.app.box.com/representation/file_version_73046098109/image_2048/1.png?shared_name=8caxu7n4o0sacctzjz9j86fn8zst3l65)

**Swift SDK for DB2**

[![Build Status - Master](https://travis-ci.org/IBM-DTeam/swift-for-db2.svg?branch=master)](https://travis-ci.org/IBM-DTeam/swift-for-db2)
![Mac OS X](https://img.shields.io/badge/os-Mac%20OS%20X-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)

## Summary

The Swift SDK for DB2 allows you to connect to your IBM DB2 database or products based off IBM DB2 and execute queries in Swift.

## Table of Contents
* [Summary](#summary)
* [Features](#features)
* [Swift Version](#swift-version)
* [Installation (OS X)](#installation-os-x)
* [Installation (Linux)](#installation-linux)
* [Using Swift SDK for DB2](#using-swift-sdk-for-db2)
* [Examples](#examples)
* [Contributing](#contributing)
* [License](#license)

## Features:

- Connect asynchronously or synchronously to your database.
- Disconnect asynchronously or synchronously to your database.
- Query your database asynchronously or synchronously.

## Swift Version
The latest version of the Swift SDK for DB2 works with the DEVELOPMENT-SNAPSHOT-2016-05-09-a version of the Swift binaries. You can download this version of the Swift binaries by following this [link](https://swift.org/download/). Compatibility with other Swift versions is not guaranteed.

## Installation (OS X)

1. Install [Homebrew](http://brew.sh/) (if you don't already have it installed):

 `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

2. Install the necessary dependencies:

  `brew install wget unixodbc`

3. Run the following to install the Swift SDK for DB2 CLI

  `wget https://github.com/IBM-DTeam/swift-for-db2-cli/archive/master.zip && unzip master.zip && cd swift-for-db2-cli-master && sudo ./cli.sh && . env.sh && cd .. && rm -f master.zip && rm -rf swift-for-db2-cli-master`

4. Download and install the [supported Swift compiler](#swift-version).

 During installation if you are using the package installer make sure to select "all users" for the installation path in order for the correct toolchain version to be available for use with the terminal.

 After installation, make sure you update your PATH environment variable as described in the installation instructions (e.g. export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH)

5. Now you are ready to use the Swift SDK for DB2. See [Using Swift SDK for DB2](#using-swift-sdk-for-db2).


## Installation (Linux)

1. Get the newest versions of packages and their dependencies

  `sudo apt-get update`

2. Install the required dependencies

  `sudo apt-get install -y clang unixodbc-dev unzip wget tar`

3. Run the following to install the Swift SDK for DB2 CLI

  `wget https://github.com/IBM-DTeam/swift-for-db2-cli/archive/master.zip && unzip master.zip && cd swift-for-db2-cli-master && sudo ./cli.sh && . env.sh && cd .. && rm -f master.zip && rm -rf swift-for-db2-cli-master`

4. Install the [supported Swift compiler](#swift-version) for Linux.

 Follow the instructions provided on that page. After installing it (i.e. uncompressing the tar file), make sure you update your PATH environment variable so that it includes the extracted tools: `export PATH=/<path to uncompress tar contents>/usr/bin:$PATH`. To update the PATH env variable, you can update your [.bashrc file](http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html).

5. Clone, build and install the libdispatch library.
The complete instructions for building and installing this library are  [here](https://github.com/apple/swift-corelibs-libdispatch/blob/experimental/foundation/INSTALL), though, all you need to do is just this
 `git clone -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git && cd swift-corelibs-libdispatch && git submodule init && git submodule update && sh ./autogen.sh && ./configure --with-swift-toolchain=<path-to-swift>/usr --prefix=<path-to-swift>/usr && make && make install`

6. Now you are ready to use the Swift SDK for DB2. See [Using Swift SDK for DB2](#using-swift-sdk-for-db2).


## Using Swift SDK for DB2
1. Create the ``` Package.swift ``` file in your project folder, and add the following code

 ```swift
import PackageDescription

let package = Package(
    name: "your_project_name",
    dependencies: [
        .Package(url: "https://github.com/IBM-DTeam/swift-for-db2.git", majorVersion: 1)
    ]
)
 ```
 If you already had the ```Package.swift``` file, add the following line under ```dependencies```

 ```swift
 .Package(url: "https://github.com/IBM-DTeam/swift-for-db2.git", majorVersion: 1)
 ```

 2.Then, run the following command in terminal (in your project folder)

 ### OS X
 ```
 swift build -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib
 ```

 ### Linux
 ```
 swift build -Xcc -fblocks -Xlinker -ldispatch
 ```

 3.Wait until the build finishes, then run the project
 ```
 .build/debug/your_project_name
 ```

## Examples
Visit the [Wiki](https://github.com/IBM-DTeam/swift-for-db2/wiki) for examples on how to use the Swift SDK for DB2.

## Contributing
1. Clone this repository, `git clone https://github.com/IBM-DTeam/swift-for-db2`
2. Build and run tests

  ### Notes
  * You are required to set the environment variable DB2_CONN_STRING to your database connection string.

You can find info on contributing to Swift SDK for DB2 in our [contributing guidelines](CONTRIBUTING.md).

## License
This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).
