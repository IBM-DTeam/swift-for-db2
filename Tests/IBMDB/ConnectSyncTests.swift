/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
@testable import IBMDB

#if os(Linux)
import Glibc
#else
import Darwin
#endif

class ConnectSyncTests : XCTestCase {

  static var allTests : [(String, (ConnectSyncTests) -> () throws -> Void)] {
    return [
    ("testConnectSyncValidConfig", testConnectSyncValidConfig),
    ("testConnectSyncInvalidConfig", testConnectSyncInvalidConfig)

    ]
  }


  let db = IBMDB()
  let connStringInvalid = "DRIVER={DB2};DATABASE=someDB;UID=someUID;PWD=somePWD;HOSTNAME=someHost;PORT=somePort"


  func testConnectSyncValidConfig() {

    var connStringValid: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connStringValid = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connStringValid == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(info: connStringValid!)
    XCTAssertNil(info.error, "conn.error is Nil")
    XCTAssertNotNil(info.connection, "conn.connection is not Nil")
  }

  func testConnectSyncInvalidConfig() {

    let info = db.connectSync(info: connStringInvalid)
    XCTAssertNotNil(info.error, "conn.error is not Nil")
    XCTAssertNil(info.connection, "conn.connection is Nil")
  }

}
