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

class QueryTests : XCTestCase {

  private static var ranSetup = false

  static var allTests : [(String, (QueryTests) -> () throws -> Void)] {
    return [
      ("testQueryAInsert", testQueryAInsert),
      ("testQueryAInsert100", testQueryAInsert100),
      ("testQueryAInsert1000", testQueryAInsert1000),
      ("testQueryBSelect", testQueryBSelect),
      ("testQueryBSelect100", testQueryBSelect100),
      ("testQueryBSelect1000", testQueryBSelect1000),
      ("testQueryCUpdate", testQueryCUpdate),
      ("testQueryCUpdate100", testQueryCUpdate100),
      ("testQueryCUpdate1000", testQueryCUpdate1000),
      ("testQueryDDelete", testQueryDDelete),
      ("testQueryDDelete100", testQueryDDelete100),
      ("testQueryDDelete1000", testQueryDDelete1000)
    ]
  }

  let db = IBMDB()
  #if os(Linux)
  private static var tableName = "DB2_TEST_TABLE_LINUX_" + String.getRandom(length: 1 + Int(random() % (100)))
  #else
  private static var tableName = "DB2_TEST_TABLE_DARWIN_" + String.getRandom(length: 1 + Int(arc4random_uniform(100)))
  #endif

  override func setUp() {
    super.setUp()

    if QueryTests.ranSetup {
      return
    }

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      return
    }

    let info = db.connectSync(info: connString!)

    if info.error != nil {
      return
    }

    let conn = info.connection

    let dropTableQuery = "DROP TABLE " + QueryTests.tableName

    conn!.querySync(query: dropTableQuery)

    let createTableQuery = "CREATE TABLE \(QueryTests.tableName) (ID INTEGER NOT NULL, TEXT VARCHAR(256) NOT NULL)"

    conn!.querySync(query: createTableQuery)

    QueryTests.ranSetup = true

  }

  override func tearDown() {
    super.tearDown()
  }

  func testQueryBSelect() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      #if os(Linux)
      let id = 1 + Int(random() % (1101))
      #else
      let id = 1 + Int(arc4random_uniform(1101))
      #endif

      let query = "SELECT * FROM \(QueryTests.tableName) WHERE ID=\(id)"

      connection!.query(query: query) { (result, error) -> Void in

        if error != nil {
          XCTFail(error!.description)
        }

        XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

        expectation.fulfill()

      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }


  }

  func testQueryBSelect100() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      var numFinished = 0
      for _ in 1...100 {

        #if os(Linux)
        let id = 1 + Int(random() % (1101))
        #else
        let id = 1 + Int(arc4random_uniform(1101))
        #endif

        let query = "SELECT * FROM \(QueryTests.tableName) WHERE ID=\(id)"

        connection!.query(query: query) { (result, error) -> Void in

          if error != nil {
            XCTFail(error!.description)
          }

          if result.count >= 0 {
            numFinished += 1
          }

          XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

          if numFinished == 100 {
            expectation.fulfill()
          }

        }
      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryBSelect1000() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      var numFinished = 0
      for _ in 1...1000 {

        #if os(Linux)
        let id = 1 + Int(random() % (1101))
        #else
        let id = 1 + Int(arc4random_uniform(1101))
        #endif

        let query = "SELECT * FROM \(QueryTests.tableName) WHERE ID=\(id)"

        connection!.query(query: query) { (result, error) -> Void in

          if error != nil {
            XCTFail(error!.description)
          }

          if result.count >= 0 {
            numFinished += 1
          }

          XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

          if numFinished == 1000 {
            expectation.fulfill()
          }

        }
      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryDDelete() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      let query = "DELETE FROM \(QueryTests.tableName) WHERE ID=1"

      connection!.query(query: query) { (result, error) -> Void in

        if error != nil {
          XCTFail(error!.description)
        }

        XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

        expectation.fulfill()

      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryDDelete100() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      var numFinished = 0
      for id in 2...101 {
        let query = "DELETE FROM \(QueryTests.tableName) WHERE ID=\(id)"

        connection!.query(query: query) { (result, error) -> Void in

          if error != nil {
            XCTFail(error!.description)
          }

          if result.count >= 0 {
            numFinished += 1
          }

          XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

          if numFinished == 100 {
            expectation.fulfill()
          }

        }
      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryDDelete1000() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      var numFinished = 0
      for id in 102...1101 {
        let query = "DELETE FROM \(QueryTests.tableName) WHERE ID=\(id)"

        connection!.query(query: query) { (result, error) -> Void in

          if error != nil {
            XCTFail(error!.description)
          }

          if result.count >= 0 {
            numFinished += 1
          }

          XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

          if numFinished == 1000 {
            expectation.fulfill()
          }

        }
      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryCUpdate() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      #if os(Linux)
      let randomString = String.getRandom(length: 1 + Int(random() % (256)))
      #else
      let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
      #endif

      let query = "UPDATE \(QueryTests.tableName) SET TEXT='\(randomString)' WHERE ID=1"

      connection!.query(query: query) { (result, error) -> Void in

        if error != nil {
          XCTFail(error!.description)
        }

        XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

        expectation.fulfill()

      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryCUpdate100() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      var numFinished = 0
      for _ in 1...100 {

        #if os(Linux)
        let randomString = String.getRandom(length: 1 + Int(random() % (256)))
        #else
        let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
        #endif

        let query = "UPDATE \(QueryTests.tableName) SET TEXT='\(randomString)' WHERE ID=1"

        connection!.query(query: query) { (result, error) -> Void in

          if error != nil {
            XCTFail(error!.description)
          }

          if result.count >= 0 {
            numFinished += 1
          }

          XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

          if numFinished == 100 {
            expectation.fulfill()
          }

        }
      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryCUpdate1000() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      var numFinished = 0
      for _ in 1...1000 {

        #if os(Linux)
        let randomString = String.getRandom(length: 1 + Int(random() % (256)))
        #else
        let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
        #endif

        let query = "UPDATE \(QueryTests.tableName) SET TEXT='\(randomString)' WHERE ID=1"

        connection!.query(query: query) { (result, error) -> Void in

          if error != nil {
            XCTFail(error!.description)
          }

          if result.count >= 0 {
            numFinished += 1
          }

          XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

          if numFinished == 1000 {
            expectation.fulfill()
          }

        }
      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }
  }

  func testQueryAInsert() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      #if os(Linux)
      let randomString = String.getRandom(length: 1 + Int(random() % (256)))
      #else
      let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
      #endif

      let query = "INSERT INTO " + QueryTests.tableName + " (ID, TEXT) VALUES (1, '\(randomString)')"

      connection!.query(query: query) { (result, error) -> Void in

        if error != nil {
          XCTFail(error!.description)
        }

        XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

        expectation.fulfill()

      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryAInsert100() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      var numFinished = 0
      for id in 2...101 {

        #if os(Linux)
        let randomString = String.getRandom(length: 1 + Int(random() % (256)))
        #else
        let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
        #endif

        let query = "INSERT INTO " + QueryTests.tableName + " (ID, TEXT) VALUES (\(id), '\(randomString)')"

        connection!.query(query: query) { (result, error) -> Void in

          if error != nil {
            XCTFail(error!.description)
          }

          if result.count >= 0 {
            numFinished += 1
          }

          XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

          if numFinished == 100 {
            expectation.fulfill()
          }

        }
      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }

  func testQueryAInsert1000() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let expectation = self.expectation(withDescription: "Attempts to connect to the database and runs queries.")

    db.connect(info: connString!) { (error, connection) -> Void in
      if error != nil {
        XCTFail("Cannot connect to DB2.")
      }

      var numFinished = 0
      for id in 102...1101 {

        #if os(Linux)
        let randomString = String.getRandom(length: 1 + Int(random() % (256)))
        #else
        let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
        #endif

        let query = "INSERT INTO " + QueryTests.tableName + " (ID, TEXT) VALUES (\(id), '\(randomString)')"

        connection!.query(query: query) { (result, error) -> Void in

          if error != nil {
            XCTFail(error!.description)
          }

          if result.count >= 0 {
            numFinished += 1
          }

          XCTAssertGreaterThanOrEqual(result.count, 0, "Got a result set with 0 or more rows.")

          if numFinished == 1000 {
            expectation.fulfill()
          }

        }
      }

    }

    self.waitForExpectations(withTimeout: 600) { error in
      if let error = error {
        XCTFail("waitForExpectationsWithTimeout errored: \(error)")
      }
    }

  }
}
