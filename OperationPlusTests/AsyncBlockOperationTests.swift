//
//  AsyncBlockOperationTests.swift
//  OperationPlusTests
//
//  Created by Matt Massicotte on 2019-02-03.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import XCTest
import OperationTestingPlus
@testable import OperationPlus

class AsyncBlockOperationTests: XCTestCase {
    func testCallingCompletionBlock() {
        let op = AsyncBlockOperation { (completionBlock) in
            DispatchQueue.global().async {
                completionBlock()
            }
        }

        XCTAssertTrue(op.isAsynchronous)
        
        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
    }

    func testNeverCallingCompletionBlock() {
        let op = AsyncBlockOperation { (completionBlock) in
        }

        let expectation = OperationExpectation(operation: op)
        expectation.isInverted = true

        wait(for: [expectation], timeout: 0.1)

        XCTAssertTrue(op.isReady)
        XCTAssertFalse(op.isFinished)
        XCTAssertFalse(op.isCancelled)
    }
}
