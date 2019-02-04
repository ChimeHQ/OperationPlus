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
    typealias ExecutionHandler = (MockOperation) -> Void

    var handledError: BaseOperationError?
    var executionHandler: ExecutionHandler

    init(timeout: TimeInterval = .greatestFiniteMagnitude, executeBlock: ExecutionHandler? = nil) {
        self.executionHandler = executeBlock ?? { op in
            op.finish()
        }

        super.init(timeout: timeout)
    }

    override func handleError(_ error: BaseOperationError) {
        handledError = error
    }

    override func main() {
        executionHandler(self)
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

    func testKVONotifications() {
        let op = MockOperation()

        let executingKVOExpectation = XCTKVOExpectation(keyPath: "isExecuting", object: op, expectedValue: true)
        let finishedKVOExpectation = XCTKVOExpectation(keyPath: "isFinished", object: op, expectedValue: true)

        let expectations = [
            executingKVOExpectation,
            finishedKVOExpectation,
        ]

        // I couldn't figure out a way to correctly synchronize isFinished with
        // detecting completion using an OperationExpectation. So, I just
        // seperated out the two waits. Not ideal, but also not flakey.
        let completionExpectation = OperationExpectation(operation: op)

        wait(for: expectations, timeout: 1.0, enforceOrder: true)
        wait(for: [completionExpectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
    }
}

extension BaseOperationTests {
    func testFinishBeforeStartingIsInvalid() {
        let op = MockOperation()

        XCTAssertNil(op.handledError)

        op.finish()

        XCTAssertEqual(op.handledError, BaseOperationError.stateTransitionInvalid(.finished))
    }

    func testTimeoutBeforeStartingIsInvalid() {
        let op = MockOperation()

        XCTAssertNil(op.handledError)

        op.timedOut()

        XCTAssertEqual(op.handledError, BaseOperationError.stateTransitionInvalid(.timedOut))
    }

    func testDoubleFinishIsInvalid() {
        let op = MockOperation(executeBlock: { (o) in
            o.finish()
            o.finish()
        })

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(op.handledError, BaseOperationError.stateTransitionInvalid(.finished))
    }

    func testFinishAfterTimeoutIsValid() {
        let op = MockOperation(timeout: 1.0, executeBlock: { (o) in
            sleep(2)
            o.finish()
        })

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 3.0)

        XCTAssertNil(op.handledError)
        XCTAssertTrue(op.isTimedOut)
        XCTAssertTrue(op.isFinished)
    }
}
