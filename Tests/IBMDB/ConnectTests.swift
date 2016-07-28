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

class ConnectTests : XCTestCase {

  static var allTests : [(String, (ConnectTests) -> () throws -> Void)] {
    return [
    ("testConnectValidConfig", testConnectValidConfig),
    ("testConnectInvalidConfig", testConnectInvalidConfig),

    ]
  }


  let db = IBMDB()
  let connStringInvalid = "DRIVER={DB2};DATABASE=someDB;UID=someUID;PWD=somePWD;HOSTNAME=someHost;PORT=somePort"


  func testConnectValidConfig() {

    var connStringValid: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connStringValid = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connStringValid == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs the callback closure")

    db.connect(info: connStringValid!) { (error, connection) -> Void in
      XCTAssertNil(error, "error is Nil")
      XCTAssertNotNil(connection, "connection is not Nil")
      expectation.fulfill()
    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testConnectInvalidConfig() {

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs the callback closure")

    db.connect(info: connStringInvalid) { (error, connection) -> Void in
      XCTAssertNotNil(error, "error is not Nil")
      XCTAssertNil(connection, "connection is Nil")
      expectation.fulfill()
    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }
}
