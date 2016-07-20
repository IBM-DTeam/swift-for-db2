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

class DisconnectTests : XCTestCase {

  static var allTests : [(String, (DisconnectTests) -> () throws -> Void)] {
    return [
    ("testDisconnect", testDisconnect)

    ]
  }


  let db = IBMDB()

  func testDisconnect() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(info: connString!)

    var conn: Connection? = nil
    if (info.connection != nil) {
      conn = info.connection
    } else {
      XCTFail("Cannot establish a connection to the database.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect and disconnect from the database and runs the callback closure")

    conn!.disconnect() { () -> Void in
      XCTAssertNotNil(conn!.info().error, "Cannot fetch database info.")
      expectation.fulfill()
    }

    self.waitForExpectations(withTimeout: 300) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }
}
