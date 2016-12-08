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

class DisconnectSyncTests : XCTestCase {

  static var allTests : [(String, (DisconnectSyncTests) -> () throws -> Void)] {
    return [
    ("testDisconnectSync", testDisconnectSync)
    ]
  }


  let db = IBMDB()

  func testDisconnectSync() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let _info = db.connectSync(connString: connString!)

    let disc = db.disconnectSync()
    XCTAssertNotNil(disc == 1, "Cannot fetch database info.")

  }


}
