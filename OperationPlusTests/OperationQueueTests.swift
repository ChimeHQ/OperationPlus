//
//  OperationQueueTests.swift
//  OperationTests
//
//  Created by Matt Massicotte on 2019-01-30.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import XCTest
import OperationTestingPlus
@testable import OperationPlus

class OperationQueueTests: XCTestCase {
    func testDependencies() {
        let opA = Operation()
        let opB = Operation()
        let queue = OperationQueue()

        queue.addOperation(opA, dependencies: [opB])

        XCTAssertEqual(opA.dependencies, [opB])
    }

    func testConvenienceInitializer() {
        let queue = OperationQueue(name: "MyQueue", maxConcurrentOperations: 10)

        XCTAssertEqual(queue.name, "MyQueue")
        XCTAssertEqual(queue.maxConcurrentOperationCount, 10)
    }

    func testConvenienceInitializerDefault() {
        let queue = OperationQueue(name: "MyQueue")

        XCTAssertEqual(queue.name, "MyQueue")
        XCTAssertEqual(queue.maxConcurrentOperationCount, OperationQueue.defaultMaxConcurrentOperationCount)
    }

    func testCurrentOperationsCompleteHandler() {
        let queue = OperationQueue()

        let opExpectation = OperationExpectation(operation: Operation(), queue: queue)

        let finishedExpectation = XCTestExpectation(description: "Queue finished block invoked")

        queue.currentOperationsFinished {
            finishedExpectation.fulfill()
        }

        wait(for: [opExpectation, finishedExpectation], timeout: 0.1, enforceOrder: true)
    }

    func testPreconditionMain() {
        OperationQueue.preconditionMain()
    }

    func testPreconditionNotMain() {
        let op = BlockOperation {
            OperationQueue.preconditionNotMain()
        }

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 1.0)
    }

    func testAddAsyncBlock() {
        let queue = OperationQueue.serialQueue()

        let blockExpecation = XCTestExpectation(description: "Block Expectation")

        queue.addAsyncOperation { (completionHandler) in
            blockExpecation.fulfill()
            completionHandler()
        }

        let nextOpExpectation = OperationExpectation(operation: Operation(), queue: queue)

        wait(for: [blockExpecation, nextOpExpectation], timeout: 1.0, enforceOrder: true)
    }

    func testAddOperationAfterDelay() {
        let queue = OperationQueue()
        let op = Operation()
        let dependentOp = Operation()
        dependentOp.addDependency(op)

        queue.addOperation(op, afterDelay: 1.0)

        let expectation = OperationExpectation(operation: dependentOp, queue: queue)

        wait(for: [expectation], timeout: 2.0)
    }
}
