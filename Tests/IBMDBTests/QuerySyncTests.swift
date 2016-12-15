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
import IBMDBLinker

#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension String {

  static func getRandom(length: Int = 50) -> String {

    let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var randomString: String = ""

    for _ in 0..<length {
      #if os(Linux)
      let randomValue = random() % base.characters.count
      #else
      let randomValue = Int(arc4random_uniform(UInt32(base.characters.count)))
      #endif

      var current = 0
      for character in base.characters {
        if randomValue == current {
          randomString += String(character)
        }

        current += 1

      }

    }

    return randomString
  }
}

class QuerySyncTests : XCTestCase {

  private static var ranSetup = false

  static var allTests : [(String, (QuerySyncTests) -> () throws -> Void)] {
    return [
    ("testQuerySyncAInsert", testQuerySyncAInsert),
    ("testQuerySyncAInsert100", testQuerySyncAInsert100),
    ("testQuerySyncAInsert1000", testQuerySyncAInsert1000),
    ("testQuerySyncBSelect", testQuerySyncBSelect),
    ("testQuerySyncBSelect100", testQuerySyncBSelect100),
    ("testQuerySyncBSelect1000", testQuerySyncBSelect1000),
    ("testQuerySyncCUpdate", testQuerySyncCUpdate),
    ("testQuerySyncCUpdate100", testQuerySyncCUpdate100),
    ("testQuerySyncCUpdate1000", testQuerySyncCUpdate1000),
    ("testQuerySyncDDelete", testQuerySyncDDelete),
    ("testQuerySyncDDelete100", testQuerySyncDDelete100),
    ("testQuerySyncDDelete1000", testQuerySyncDDelete1000)
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

    if QuerySyncTests.ranSetup {
      return
    }

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      return
    }

    let info = db.connectSync(connString: connString!)
    
    if info != 1{
        
    }

    let dropTableQuery = "DROP TABLE " + QuerySyncTests.tableName
    
    var htmt: UnsafeMutablePointer<queryStruct>?
    
    let drop = db.query(queryString: dropTableQuery, hstmt: &htmt)
    
    if drop != 1{
        
    }

    let createTableQuery = "CREATE TABLE \(QuerySyncTests.tableName) (ID INTEGER NOT NULL, TEXT VARCHAR(256) NOT NULL)"

    let create = db.query(queryString: createTableQuery, hstmt: &htmt)
    
    if create != 1{
        
    }

    QuerySyncTests.ranSetup = true

  }

  override func tearDown() {
    super.tearDown()
  }

  func testQuerySyncBSelect() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    #if os(Linux)
    let id = 1 + Int(random() % (1101))
    #else
    let id = 1 + Int(arc4random_uniform(1101))
    #endif
    let query = "SELECT * FROM \(QuerySyncTests.tableName) WHERE ID=\(id)"
    
    var htmt: UnsafeMutablePointer<queryStruct>?

    let response = db.query(queryString: query, hstmt: &htmt)

    if response != 1{
        
    }

    XCTAssertNil(response == 1 , "Query did not execute")

  }

  func testQuerySyncBSelect100() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    for _ in 1...100 {

      #if os(Linux)
      let id = 1 + Int(random() % (1101))
      #else
      let id = 1 + Int(arc4random_uniform(1101))
      #endif

      let query = "SELECT * FROM \(QuerySyncTests.tableName) WHERE ID=\(id)"
        
      var htmt: UnsafeMutablePointer<queryStruct>?

      let response = db.query(queryString: query, hstmt: &htmt)

        if response != 1{
            
        }

      XCTAssertNil(response == 1 , "Query did not execute")
    }


  }

  func testQuerySyncBSelect1000() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }


    for _ in 1...1000 {

      #if os(Linux)
      let id = 1 + Int(random() % (1101))
      #else
      let id = 1 + Int(arc4random_uniform(1101))
      #endif

      let query = "SELECT * FROM \(QuerySyncTests.tableName) WHERE ID=\(id)"

      var htmt: UnsafeMutablePointer<queryStruct>?
      let response = db.query(queryString: query, hstmt: &htmt)

        if response != 1{
            
        }

      XCTAssertNil(response == 1 , "Query did not execute")
    }

  }

  func testQuerySyncDDelete() {

    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }
 
    let query = "DELETE FROM \(QuerySyncTests.tableName) WHERE ID=1"
    
    var htmt: UnsafeMutablePointer<queryStruct>?
    
    let response = db.query(queryString: query, hstmt: &htmt)

    XCTAssertNil(response == 1 , "Query did not execute")

  }

  func testQuerySyncDDelete100() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    for id in 2...101 {
      let query = "DELETE FROM \(QuerySyncTests.tableName) WHERE ID=\(id)"
      
      var htmt: UnsafeMutablePointer<queryStruct>?
      let response = db.query(queryString: query, hstmt: &htmt)


      XCTAssertNil(response == 1 , "Query did not execute")
    }

  }

  func testQuerySyncDDelete1000() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    for id in 102...1101 {
      let query = "DELETE FROM \(QuerySyncTests.tableName) WHERE ID=\(id)"
      
      var htmt: UnsafeMutablePointer<queryStruct>?
      let response = db.query(queryString: query, hstmt: &htmt)

      XCTAssertNil(response == 1 , "Query did not execute")
    }
  }

  func testQuerySyncCUpdate() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    #if os(Linux)
    let randomString = String.getRandom(length: 1 + Int(random() % (256)))
    #else
    let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
    #endif

    let query = "UPDATE \(QuerySyncTests.tableName) SET TEXT='\(randomString)' WHERE ID=1"
    
    var htmt: UnsafeMutablePointer<queryStruct>?
    
    let response = db.query(queryString: query, hstmt: &htmt)


    XCTAssertNil(response == 1 , "Query did not execute")
  }

  func testQuerySyncCUpdate100() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    for id in 2...101 {

      #if os(Linux)
      let randomString = String.getRandom(length: 1 + Int(random() % (256)))
      #else
      let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
      #endif

      let query = "UPDATE \(QuerySyncTests.tableName) SET TEXT='\(randomString)' WHERE ID=\(id)"
        
      var htmt: UnsafeMutablePointer<queryStruct>?
      let response = db.query(queryString: query, hstmt: &htmt)

        if response != 1{
            
        }

      XCTAssertNil(response == 1 , "Query did not execute")
    }

  }

  func testQuerySyncCUpdate1000() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }



    for id in 102...1101 {

      #if os(Linux)
      let randomString = String.getRandom(length: 1 + Int(random() % (256)))
      #else
      let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
      #endif

      let query = "UPDATE \(QuerySyncTests.tableName) SET TEXT='\(randomString)' WHERE ID=\(id)"
      var htmt: UnsafeMutablePointer<queryStruct>?
      let response = db.query(queryString: query, hstmt: &htmt)

        if response != 1{
            
        }

      XCTAssertNil(response == 1 , "Query did not execute")
    }
  }

  func testQuerySyncAInsert() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    #if os(Linux)
    let randomString = String.getRandom(length: 1 + Int(random() % (256)))
    #else
    let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
    #endif

    let query = "INSERT INTO \(QuerySyncTests.tableName) (ID, TEXT) VALUES (1, '\(randomString)')"
    var htmt: UnsafeMutablePointer<queryStruct>?
    let response = db.query(queryString: query, hstmt: &htmt)


    XCTAssertNil(response == 1 , "Query did not execute")

  }

  func testQuerySyncAInsert100() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    for id in 2...101 {

      #if os(Linux)
      let randomString = String.getRandom(length: 1 + Int(random() % (256)))
      #else
      let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
      #endif
      let query = "INSERT INTO \(QuerySyncTests.tableName) (ID, TEXT) VALUES (\(id), '\(randomString)')"
        
      var htmt: UnsafeMutablePointer<queryStruct>?

      let response = db.query(queryString: query, hstmt: &htmt)

      XCTAssertNil(response == 1 , "Query did not execute")
    }
  }

  func testQuerySyncAInsert1000() {
    var connString: String? = nil

    if getenv("DB2_CONN_STRING") != nil {
      connString = String(validatingUTF8: getenv("DB2_CONN_STRING"))
    }

    if connString == nil {
      XCTFail("Environment Variable DB2_CONN_STRING not set.")
    }

    let info = db.connectSync(connString: connString!)
    if info != 1{
        
    }

    for id in 102...1101 {

      #if os(Linux)
      let randomString = String.getRandom(length: 1 + Int(random() % (256)))
      #else
      let randomString = String.getRandom(length: 1 + Int(arc4random_uniform(256)))
      #endif

      let query = "INSERT INTO " + QuerySyncTests.tableName + " (ID, TEXT) VALUES (\(id), '\(randomString)')"
       var htmt: UnsafeMutablePointer<queryStruct>?
      let response = db.query(queryString: query, hstmt: &htmt)

      XCTAssertNil(response == 1 , "Query did not execute")
    }
  }

}
