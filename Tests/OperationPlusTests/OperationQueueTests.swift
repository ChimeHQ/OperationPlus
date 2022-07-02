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
    func testSerialCreation() {
        let queue = OperationQueue.serialQueue()

        XCTAssertEqual(queue.maxConcurrentOperationCount, 1)
    }

    func testNamedSerialCreation() {
        let queue = OperationQueue.serialQueue(named: "myqueue")

        XCTAssertEqual(queue.name, "myqueue")
        XCTAssertEqual(queue.maxConcurrentOperationCount, 1)
    }

    func testDependencies() {
        let opA = Operation()
        let opB = Operation()
        let queue = OperationQueue()

        queue.addOperation(opA, dependencies: [opB])

        XCTAssertEqual(opA.dependencies, [opB])
    }

    func testDependency() {
        let opA = Operation()
        let opB = Operation()
        let queue = OperationQueue()

        queue.addOperation(opA, dependency: opB)

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

        queue.addOperation(op, afterDelay: 0.1)

        let expectation = OperationExpectation(operation: dependentOp, queue: queue)

        wait(for: [expectation], timeout: 0.5)
    }

    func testAddDependencies() {
        let queue = OperationQueue()
        let opA = Operation()
        let opB = Operation()
        let opC = Operation()

        queue.addOperations([opA, opB])
        queue.addOperation(opC, dependencies: [opB, opA])

        XCTAssertEqual(opA.dependencies.count, 0)
        XCTAssertEqual(opB.dependencies.count, 0)
        XCTAssertEqual(opC.dependencies.count, 2)
        XCTAssertTrue(opC.dependencies.contains(opA))
        XCTAssertTrue(opC.dependencies.contains(opB))
    }

    func testAddSetDependencies() {
        let queue = OperationQueue()
        let opA = Operation()
        let opB = Operation()
        let opC = Operation()

        queue.addOperations([opA, opB])
        queue.addOperation(opC, dependencies: Set([opB, opA]))

        XCTAssertEqual(opA.dependencies.count, 0)
        XCTAssertEqual(opB.dependencies.count, 0)
        XCTAssertEqual(opC.dependencies.count, 2)
        XCTAssertTrue(opC.dependencies.contains(opA))
        XCTAssertTrue(opC.dependencies.contains(opB))
    }

    func testAddOperationAsync() {
        let queue = OperationQueue()

        let expectation = XCTestExpectation()

        queue.addOperation {
            await Task { }.value

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.5)
    }

    func testAddResultOperationAsync() async throws {
        let queue = OperationQueue()

        let value = try await queue.addResultOperation {
            return 5
        }

        XCTAssertEqual(value, 5)
    }
}
