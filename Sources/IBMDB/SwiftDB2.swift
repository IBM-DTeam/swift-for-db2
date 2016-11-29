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
import IBMDBLinker

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

// Custom named queue
let queue = DispatchQueue(label: "swift-for-db2", attributes: Dispatch.DispatchQueue.Attributes.concurrent)

public class IBMDB {

	var db: UnsafeMutablePointer<database>?

	/**
     * Empty constructor to initialize IBMDB.
     */
	public init() {
		db = nil;
	}
    
    
    /**
     * Gets the database struct associated with the instance
     *
     * Returns:
     *     db: The database struct
     */
    
	public func getConnection() -> UnsafeMutablePointer<database>? {
		return db;
	}
    
    
    /**
     * Connects to the database asyncronously
     *
     */
	public func connect(connString: String, withCompletion: @escaping (state!) -> Void) -> Void {

		queue.sync {
			let s: state = self.connectSync(connString: connString);
			withCompletion(s);
		}

	}
    
    /**
     * Connects synchronously from the database
     *
     * Returns:
     *     s: returns the state of the function
     */
	public func connectSync(connString: String) -> state! {

		// Try to connect to the database
		let s: state = connString.withCString { cConnString in
			db_connect(&db, cConnString);
		}

		return s;

	}
    
    /**
     * Disconnect asynchronously from the database
     */
    
    public func disconnect(withCompletion: @escaping (state!) -> Void) -> Void {
        queue.sync {
            let s: state = self.disconnectSync();
            withCompletion(s);
        }
    }
    
    
    /**
     * Disconnect synchronously from the database
     */
    public func disconnectSync() -> state!{
        let s: state = db_disconnect(&db);
        return s;
    }
    
    
    /**
     * Funtion name: Query
     * ----------------------------
     *
     * Query the databse ad hoc. Will get data and place it in the retrieve struct within the hstmtStruct. Use getNextRow/getNextColumn for data.ad
     *
     * Input:
     *   query: The query string to be executed
     *   hstmt: Pointer to a hstmt struct that holds all the data of the accociated query string
     *
     * Returns:
     *   s: The state of the function. If not successfull, use get next error to see the errors.
     *
     */
    private func query(queryString: String, hstmt: inout UnsafeMutablePointer<queryStruct>?) -> state! {
        
        let s: state = queryString.withCString { cString in
            db_query(self.db, &hstmt, UnsafeMutablePointer(mutating: cString))
        }
        return s;

    }
    
    /**
     * Funtion name: Query
     * ----------------------------
     *
     * Query the databse ad hoc. Will get data and place it in the retrieve struct within the hstmtStruct. Use getNextRow/getNextColumn for data.ad
     *
     * Input:
     *   query: The query string to be executed
     *   hstmt: Pointer to a hstmt struct that holds all the data of the accociated query string
     *
     * Returns:
     *   s: The state of the function. If not successfull, use get next error to see the errors.
     *
     *
    private func preparedQuery(queryString: String, hstmt: inout UnsafeMutablePointer<queryStruct>?, values: [String] ) -> state! {
        var cArray = CStringArray(values)
    
        let s: state = queryString.withCString { cString in
            db_prepare(self.db, &hstmt, UnsafeMutablePointer(mutating: cString), cArray.pointers[0])
        }
        return s;
        
    }
    */
    
    /**
     * Funtion name: Query
     * ----------------------------
     *
     * Query the databse ad hoc. Will get data and place it in the retrieve struct within the hstmtStruct. Use getNextRow/getNextColumn for data.ad
     *
     * Input:
     *   query: The query string to be executed
     *   hstmt: Pointer to a hstmt struct that holds all the data of the accociated query string
     *
     * Returns:
     *   s: The state of the function. If not successfull, use get next error to see the errors.
     *
     */
    private func preparedResults(hstmt: inout UnsafeMutablePointer<queryStruct>?) -> state! {
        let s: state = db_executePrepared(db, &hstmt);
        return s;
        
    }
    
    
    /**
     * Funtion name: Query
     * ----------------------------
     *
     * Query the databse ad hoc. Will get data and place it in the retrieve struct within the hstmtStruct. Use getNextRow/getNextColumn for data.ad
     *
     * Input:
     *   query: The query string to be executed
     *   hstmt: Pointer to a hstmt struct that holds all the data of the accociated query string
     *
     * Returns:
     *   s: The state of the function. If not successfull, use get next error to see the errors.
     *
     */
    private func beginTrans() -> state! {
        let s: state = db_beginTrans(&db);
        return s;
        
    }
    

    
    /**
     * Funtion name: Query
     * ----------------------------
     *
     * Query the databse ad hoc. Will get data and place it in the retrieve struct within the hstmtStruct. Use getNextRow/getNextColumn for data.ad
     *
     * Input:
     *   query: The query string to be executed
     *   hstmt: Pointer to a hstmt struct that holds all the data of the accociated query string
     *
     * Returns:
     *   s: The state of the function. If not successfull, use get next error to see the errors.
     *
     */
    private func commitTrans() -> state! {
        let s: state = db_commitTrans(&db);
        return s;
        
    }
    
    /**
     * Funtion name: Query
     * ----------------------------
     *
     * Query the databse ad hoc. Will get data and place it in the retrieve struct within the hstmtStruct. Use getNextRow/getNextColumn for data.ad
     *
     * Input:
     *   query: The query string to be executed
     *   hstmt: Pointer to a hstmt struct that holds all the data of the accociated query string
     *
     * Returns:
     *   s: The state of the function. If not successfull, use get next error to see the errors.
     *
     */
    private func rollbackTrans() -> state! {
        let s: state = db_rollbackTrans(&db);
        return s;
        
    }
    
    /**
     * Funtion name: Query
     * ----------------------------
     *
     * Query the databse ad hoc. Will get data and place it in the retrieve struct within the hstmtStruct. Use getNextRow/getNextColumn for data.ad
     *
     * Input:
     *   query: The query string to be executed
     *   hstmt: Pointer to a hstmt struct that holds all the data of the accociated query string
     *
     * Returns:
     *   s: The state of the function. If not successfull, use get next error to see the errors.
     *
     */
    private func getColumn(hstmt: inout UnsafeMutablePointer<queryStruct>?, columnName: String) -> UnsafeMutablePointer<data>! {
        let s: UnsafeMutablePointer<data> = columnName.withCString { cString in
            db_getColumn(hstmt, UnsafeMutablePointer(mutating: cString))
        }
        return s;
        
    }
    
    /**
     * Funtion name: Query
     * ----------------------------
     *
     * Query the databse ad hoc. Will get data and place it in the retrieve struct within the hstmtStruct. Use getNextRow/getNextColumn for data.ad
     *
     * Input:
     *   query: The query string to be executed
     *   hstmt: Pointer to a hstmt struct that holds all the data of the accociated query string
     *
     * Returns:
     *   s: The state of the function. If not successfull, use get next error to see the errors.
     *
     */
    private func getColumnNextRow(pointer: UnsafeMutablePointer<data>!) -> UnsafeMutablePointer<data>! {
        let s: UnsafeMutablePointer<data>!  = db_getColumnNextRow(pointer);
        return s;
        
        
    }

    

}


class CString {
    private let _len: Int
    let buffer: UnsafeMutablePointer<Int8>
    
    init(_ string: String) {
        (_len, buffer) = string.withCString {
            let len = Int(strlen($0) + 1)
            let dst = strcpy(UnsafeMutablePointer<Int8>.allocate(capacity: len), $0)
            return (len, dst!)
        }
    }
    
    deinit {
        buffer.deallocate(capacity: _len)
    }
}

class CStringArray {
    // Have to keep the owning CString's alive so that the pointers
    // in our buffer aren't dealloc'd out from under us.
    private let _strings: [CString]
    var pointers: [UnsafeMutablePointer<Int8>]
    
    init(_ strings: [String]) {
        _strings = strings.map { CString($0) }
        pointers = _strings.map { $0.buffer }
        // NULL-terminate our string pointer buffer since things like
        // exec*() and posix_spawn() require this.
        
    }
}
