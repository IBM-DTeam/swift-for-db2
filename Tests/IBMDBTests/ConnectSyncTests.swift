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
    ("testConnectSyncValidConfig", testConnectSyncValidConfig)
    ]
  }
  let db = IBMDB()
  func testConnectSyncValidConfig() {
    let connStringValid: String? =  String(validatingUTF8:
getenv("DB2_CONN_STRING"))
    if connStringValid == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }
    let state = db.connectSync(connString: connStringValid!)
    if Int(state!) != State.SUCCESS.rawValue || Int(state!) !=
State.SUCCESS_WITH_INFO.rawValue {
      XCTFail("Cannot connect to the database")
    }
  }
}
