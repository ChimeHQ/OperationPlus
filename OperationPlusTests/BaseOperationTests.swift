//
//  BaseOperationTests.swift
//  OperationTests
//
//  Created by Matt Massicotte on 2018-11-12.
//  Copyright © 2018 Chime Systems. All rights reserved.
//

import XCTest
import OperationTestingPlus
@testable import OperationPlus

class MockOperation: BaseOperation {
    var handledError: BaseOperationError?

    override func handleError(_ error: BaseOperationError) {
        handledError = error
    }
}

class BaseOperationTests: XCTestCase {
    func testCompletion() {
        let op = BaseOperation()

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 0.1)

        XCTAssertFalse(op.isTimedOut)
        XCTAssertTrue(op.isFinished)
        XCTAssertFalse(op.isCancelled)
    }

    func testTimeOut() {
        let op = NeverFinishingOperation(timeout: 1.0)

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: op.timeoutInterval * 2.0)

        XCTAssertTrue(op.isTimedOut)
        XCTAssertTrue(op.isFinished)
        XCTAssertFalse(op.isCancelled)
    }

    func testNeverFinishingOperation() {
        let op = NeverFinishingOperation()

        let expectation = OperationExpectation(operation: op)
        expectation.isInverted = true

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(op.isReady)
        XCTAssertFalse(op.isFinished)
        XCTAssertFalse(op.isCancelled)
    }

    func testAddDependencyAfterFinished() {
        let op = MockOperation()

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)

        op.addDependency(Operation())

        guard case .dependencyAddedInInvalidState? = op.handledError else {
            XCTFail("Incorrect error")
            return
        }
    }
}
