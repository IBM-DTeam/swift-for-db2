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

import Foundation
import Dispatch

// modulemaps are slightly different for each OS, need to import the correct
// ones
#if os(Linux)
    import Glibc
    import IBMCliLinux
#else
    import Darwin
    import IBMCliDarwin
#endif

// Custom named queues
#if os(Linux)
let queue = dispatch_queue_create("swift-for-db2", DISPATCH_QUEUE_CONCURRENT)
#else
let queue = DispatchQueue(label: "swift-for-db2", attributes: .concurrent)
#endif

#if os(OSX)
    public typealias DB2Dictionary = [String : AnyObject]
#else
    public typealias DB2Dictionary = [String : Any]
#endif

/**
 * IBMDB Class
 *
 * Allows the user to connect to a database.
 */
public class IBMDB {


    /**
     * Empty constructor to initialize IBMDB.
     */
    public init() {
        // Empty for now
    }

    /**
     * Async method to connect to the database using the connection string 'info'
     */
    public func connect(info: String, callback: (error: [DBError]?, connection: Connection?) -> Void) -> Void {

        var conn: UnsafeMutablePointer<ODBC>!

        func run() -> Void {
            // Try to connect to the database.
            conn = info.withCString { cString in
                db_connect(conn, UnsafeMutablePointer(cString))
            }

            if !connection_error_found(conn) {
                // Connected to the database.

                // Create a Connection object with conn to use in the callback.
                let db = Connection(conn: conn)

                callback(error: nil, connection: db)
            } else {
                // Error! Disconnect and callback with an error.
                var error_arr = [DBError]()
                var error = DBError()

                repeat{
                    error.native = Int(native_connection_error(conn))
                    error.state = String(cString: state_connection_error(conn))
                    error.description = String(cString: description_connection_error(conn))
                    error_arr.append(error)
                    conn = free_connection_error_node(conn)
                } while (connection_error_found(conn))

                db_disconnect(conn)
                callback(error: error_arr, connection: nil)
            }
        }

        #if os(Linux)
            dispatch_async(queue) {
                run()
            }
        #else
            queue.sync {
                run()
            }
        #endif


    }

    /**
     * Sync method to connect to the database using the connection string 'info'
     */
    public func connectSync(info: String) -> (error: [DBError]?, connection: Connection?) {

        var conn: UnsafeMutablePointer<ODBC>!

        // Try to connect to the database.
        conn = info.withCString { cString in
            db_connect(conn, UnsafeMutablePointer(cString))
        }

        if !connection_error_found(conn) {
            // Connected to the database.

            // Create a Connection object with conn to use in the callback.
            let db = Connection(conn: conn)

            return (error: nil, connection: db)
        } else {
            // Error! Disconnect and callback with an error.
            var error_arr = [DBError]()
            var error = DBError()

            repeat{
                error.native = Int(native_connection_error(conn))
                error.state = String(cString: state_connection_error(conn))
                error.description = String(cString: description_connection_error(conn))
                error_arr.append(error)
                conn = free_connection_error_node(conn)
            } while (connection_error_found(conn))

            db_disconnect(conn)
            return (error: error_arr, connection: nil)
        }
    }

}


/**
 * Connection Class
 *
 * The connection is established and ready to be used, we can now run operations
 * using the methods provided by the class against the database.
 */
public class Connection {

    // The database connection object
    private var conn:UnsafeMutablePointer<ODBC>!

    /**
     * Initializes the Connection object with the connected database.
     */
    public init(conn: UnsafeMutablePointer<ODBC>) {
        self.conn = conn
    }


    /**
     * Returns the database information, such as database name, version, etc....
     */
    public func info() -> DBInfo {
        let InfoPointer = db_info(self.conn)
        var Info = DBInfo()
        if InfoPointer != nil {
            Info.db_name = String(cString: return_db_name(InfoPointer))
            Info.db_version = String(cString: return_db_version(InfoPointer))
            Info.max_concur_act = String(cString: return_max_concur_act(InfoPointer))
            Info.getdata_support = String(cString: return_getdata_support(InfoPointer))
            Info.error = nil
        } else {
            Info.error = "Unable to get DB info\n"
        }
        return Info
    }


    /**
     * Runs a query asynchronously against the database.
     * Executes the callback upon completion.
     */
    public func query(query:String, callback: (result: [[DB2Dictionary]], error: [DBError]?) -> Void) -> Void {

        func run() -> Void {
            var data = [[DB2Dictionary]]()

            var response = self.data_fetch(query: query, data: &data)

            if response.success {
                callback(result: data, error: nil)
            } else {
                data.removeAll()
                if sql_error_found(response.result) {
                    callback(result: data, error: self.error(Error: DBErrorType().Fetch, result: &response.result!))
                } else {
                    callback(result: data, error: nil)
                }
            }
        }

        #if os(Linux)
            dispatch_async(queue) {
                run()
            }
        #else
            queue.sync {
                run()
            }
        #endif
    }


    /**
     * Runs a query synchronously against the database.
     * Returns a tuple of the results and error, which will be nil if there was no error.
     */
    public func querySync(query:String) -> (result: [[DB2Dictionary]]?, error: [DBError]?) {
        var data = [[DB2Dictionary]]()

        var response = self.data_fetch(query: query, data: &data)

        if response.success {
            return (result: data, error: nil)
        } else {
            data.removeAll()
            if sql_error_found(response.result) {
                return (result: data, error: self.error(Error: DBErrorType().Fetch, result: &response.result!))
            } else {
                return (result: data, error: nil)
            }
        }
    }


    /**
     * Fetches the data from the database.
     * Returns of tuple of the success status and result.
     */
    private func data_fetch(query: String, data: inout [[DB2Dictionary]]) -> (success: Bool, result: UnsafeMutablePointer<TABLE_RESULT>?) {

        var result = query.withCString { cString in
            table_fetch(self.conn, UnsafeMutablePointer(cString))
        }

        if sql_error_found(result) {
            return (false, result)
        } else {

            let row = Int(total_row(result) - 1)
            let col = Int(total_col(result))
            if !(row < 1 || col < 1) {

                for i in 1 ... row {
                    var data_col = [DB2Dictionary]()

                    for j in 1 ... col {
                        let item = self.typecast(col: j, value: String(cString: item_fetch(Int32(i), Int32(j), result)), result: &result)
                        data_col.append(item)
                    }

                    data.append(data_col)
                }

                table_clear(result)
                result = nil
                return (true, result)

            } else {
                return (false, result)
            }
        }
    }


    /**
     * Casts the type to its appropriate type from a String.
     * (Right now it returns Strings only, this will be a future feature)
     */
    private func typecast (col: Int , value: String, result: inout UnsafeMutablePointer<TABLE_RESULT>?) -> DB2Dictionary {
        let col_name = String(cString: col_name_fetch(Int32(col), result))
        if(col_name == "error"){
            return [:]
        }
        switch Int(col_data_type_fetch(Int32(col), result)) {
        default:
            #if os(Linux)
                let dict:DB2Dictionary = ["\(col_name)": String(value).bridge()]
            #else
                let dict:DB2Dictionary = ["\(col_name)" : String(value) as AnyObject]
            #endif

            return dict
        }
    }


    /**
     * Gets the database error for the user.
     */
    private func error(Error : Int, result: inout UnsafeMutablePointer<TABLE_RESULT>) -> [DBError] {
        var error_arr = [DBError]()
        var error = DBError()

        switch Error {
        case DBErrorType().Connection:
            repeat{
                error.native = Int(native_connection_error(self.conn))
                error.state = String(cString: state_connection_error(self.conn))
                error.description = String(cString: description_connection_error(self.conn))
                error_arr.append(error)
                self.conn = free_connection_error_node(self.conn)
            } while (connection_error_found(self.conn))

        case DBErrorType().Fetch , DBErrorType().Update:
            repeat{
                error.native = Int(native_sql_error(result))
                error.state = String(cString: state_sql_error(result))
                error.description = String(cString: description_sql_error(result))
                error_arr.append(error)
                result = free_sql_error_node(result)
            } while (sql_error_found(result))

        case DBErrorType().Data:
            error.native = -1
            error.state = "0"
            error.description = "Unable to fetch data\n"
            error_arr.append(error)

        default:
            error.native = -99999
            error.state = "99999"
            error.description = "Unexpected Error\n"
            error_arr.append(error)
        }
        return error_arr
    }


    /**
     * Disconnect asynchronously from the database associated with this Connection object.
     */
    public func disconnect(callback: () -> Void) -> Void {
        func run() -> Void {
            if self.conn != nil {
                db_disconnect(self.conn)
                self.conn = nil
            }
            callback()
        }

        #if os(Linux)
            dispatch_async(queue) {
                run()
            }
        #else
            queue.sync {
                run()
            }
        #endif

    }


    /**
     * Disconnect synchronously from the database associated with this Connection object.
     */
    public func disconnectSync() -> Void {
        if self.conn != nil {
            db_disconnect(self.conn)
            self.conn = nil
        }
    }
}

// Database Data Types
private struct DATATYPE {
    let SQL_UNKNOWN_TYPE = 0
    let SQL_CHAR = 1
    let SQL_NUMERIC = 2
    let SQL_DECIMAL = 3
    let SQL_INTEGER = 4
    let SQL_SMALLINT = 5
    let SQL_FLOAT = 6
    let SQL_REAL = 7
    let SQL_DOUBLE = 8
    let SQL_DATETIME = 9
    let SQL_DATE = 9
    let SQL_INTERVAL = 10
    let SQL_TIME = 10
    let SQL_TIMESTAMP = 11
    let SQL_VARCHAR = 12
    let SQL_TYPE_DATE = 91
    let SQL_TYPE_TIME = 92
    let SQL_TYPE_TIMESTAMP = 93
    let SQL_LONGVARCHAR = -1
    let SQL_BINARY = -2
    let SQL_VARBINARY = -3
    let SQL_LONGVARBINARY = -4
    let SQL_BIGINT = -5
    let SQL_TINYINT = -6
    let SQL_BIT = -7
    let SQL_WCHAR = -8
    let SQL_WVARCHAR = -9
    let SQL_WLONGVARCHAR = -10
    let SQL_GUID = -11
    let SQL_SS_VARIANT = -150
    let SQL_SS_UDT = -151
    let SQL_SS_XML = -152
    let SQL_SS_TABLE = -153
    let SQL_SS_TIME2 = -154
    let SQL_SS_TIMESTAMPOFFSET = -155
}

// Database information struct
public struct DBInfo {
    public var db_name:String?
    public var db_version:String?
    public var max_concur_act:String?
    public var getdata_support:String?
    public var error:String?
}

// Database error type struct
public struct DBErrorType {
    let Connection = 0
    let Fetch = 1
    let Update = 2
    let Data = 3
}

// Database error struct
public struct DBError {
    public var native: Int?
    public var state: String?
    public var description: String?
}
