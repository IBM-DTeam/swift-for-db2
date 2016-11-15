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

	public func getConnection() -> UnsafeMutablePointer<database>? {
		return db;
	}

	public func connect(connString: String, withCompletion: @escaping (state!) -> Void) -> Void {

		queue.sync {
			let s: state = self.connectSync(connString: connString);
			withCompletion(s);
		}

	}

	public func connectSync(connString: String) -> state! {

		// Try to connect to the database
		let s: state = connString.withCString { cConnString in
			db_connect(&db, cConnString);
		}

		return s;

	}

}
