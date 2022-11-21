//
//  XCTestCase+MemoryLeakTracking.swift
//  GiphyLookupTests
//
//  Created by Jans Pavlovs on 19/11/2022.
//

import XCTest

public extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            let message = "\(String(describing: instance)) should have been deallocated."
            XCTAssertNil(instance, message, file: file, line: line)
        }
    }
}
