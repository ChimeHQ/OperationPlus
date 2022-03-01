//
//  ProducerConsumerTests.swift
//  OperationPlusTests
//
//  Created by Matt Massicotte on 2019-02-02.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import XCTest
import OperationTestingPlus
@testable import OperationPlus

class ProducerConsumerTests: XCTestCase {
    func testProducerToConsumer() {
        let opA = IntProducerOperation(intValue: 10)
        let opB = IntConsumerOperation(producerOp: opA)

        let expectation = OperationExpectation(operations: [opA, opB])

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(opA.isFinished)
        XCTAssertTrue(opB.isFinished)
        XCTAssertEqual(opB.producerValue, 10)
    }

    func testProducerToProducerConsumerToConsumer() {
        let opA = IntProducerOperation(intValue: 42)
        let opB = IntToBoolOperation(producerOp: opA)
        let opC = BoolConsumerOperation(producerOp: opB)

        let randomOrderedOps = [opA, opB, opC].shuffled()

        let expectation = OperationExpectation(operations: randomOrderedOps)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(opA.isFinished)
        XCTAssertTrue(opB.isFinished)
        XCTAssertTrue(opC.isFinished)
        XCTAssertEqual(opC.producerValue, true)
    }

    func testFailedProducer() {
        let opA = IntProducerOperation(intValue: nil)
        let opB = IntConsumerOperation(producerOp: opA)

        let expectation = OperationExpectation(operations: [opA, opB])

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(opA.isFinished)
        XCTAssertTrue(opB.isFinished)
        XCTAssertNil(opB.producerValue)
    }

    func testMainCorrectlyInvokesFinishWithoutValue() {
        let opA = IntProducerOperation(intValue: nil)
        let opB = IntToBoolOperation(producerOp: opA)
        let opC = BoolConsumerOperation(producerOp: opB)

        let randomOrderedOps = [opA, opB, opC].shuffled()

        let expectation = OperationExpectation(operations: randomOrderedOps)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(opA.isFinished)
        XCTAssertNil(opA.value)
        XCTAssertTrue(opB.isFinished)
        XCTAssertNil(opB.producerValue)
        XCTAssertNil(opB.value)
        XCTAssertTrue(opC.isFinished)
        XCTAssertNil(opC.producerValue)
    }

    func testCallingAsyncCompletionCallback() {
        let op = AsyncBlockProducerOperation<Int> { (completionBlock) in
            DispatchQueue.global().async {
                completionBlock(42)
            }
        }

        XCTAssertNil(op.value)
        XCTAssertTrue(op.isAsynchronous)

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
        XCTAssertEqual(op.value, 42)
    }

    func testReturningValueFromBlockProducer() {
        let op = BlockProducerOperation<Int> {
            return 42
        }

        XCTAssertNil(op.value)

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
        XCTAssertEqual(op.value, 42)
    }

    func testReturningNilFromBlockProducer() {
        let op = BlockProducerOperation<Int> {
            return nil
        }

        XCTAssertNil(op.value)

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
        XCTAssertNil(op.value)
    }

    func testCachingFromProducerOperation() {
        let op = IntProducerOperation(intValue: 42)
        var writeValue = 0

        op.readCacheBlock = { 5 }
        op.writeCacheBlock = { writeValue = $0 }

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
        XCTAssertEqual(op.value, 5)
        XCTAssertEqual(writeValue, 5)
    }

    func testBlockConsumerProducerOperation() {
        let opA = IntProducerOperation(intValue: 10)
        let blockOp = BlockConsumerProducerOperation<Int, Int>(producerOp: opA) { (producedValue) in
            return producedValue * 10
        }
        let opB = IntConsumerOperation(producerOp: blockOp)

        let expectation = OperationExpectation(operations: [opA, blockOp, opB])

        wait(for: [expectation], timeout: 1.0)

        XCTAssertTrue(opA.isFinished)
        XCTAssertTrue(blockOp.isFinished)
        XCTAssertEqual(blockOp.producerValue, 10)
        XCTAssertTrue(opB.isFinished)
        XCTAssertEqual(opB.producerValue, 100)
    }

    func testProducerTimeOutValue() {
        let op = NeverFinishingProducerOperation<Int>(timeout: 0.1)
        op.outputCompletionBlockBehavior = .onTimeOut(10)

        let expectation = OperationExpectation(operation: op)

        wait(for: [expectation], timeout: op.timeoutInterval * 2.0)

        XCTAssertTrue(op.isTimedOut)
        XCTAssertTrue(op.isFinished)
        XCTAssertTrue(op.isCancelled)
        XCTAssertEqual(op.value, 10)
    }

    func testAsyncBlockConsumerOperation() {
        let opA = IntProducerOperation(intValue: 10)

        let valueExpectation = expectation(description: "Got Value")

        let blockOp = AsyncBlockConsumerOperation<Int>(producerOp: opA) { (value, opCompletionBlock) in
            DispatchQueue.global().async {
                if value == 10 {
                    valueExpectation.fulfill()
                }
                opCompletionBlock()
            }
        }

        let opExpectation = OperationExpectation(operations: [opA, blockOp])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(opA.isFinished)
        XCTAssertTrue(blockOp.isFinished)
    }

    func testBlockConsumerOperation() {
        let opA = IntProducerOperation(intValue: 10)

        let valueExpectation = expectation(description: "Got Value")

        let blockOp = BlockConsumerOperation<Int>(producerOp: opA) { (value) in
            if value == 10 {
                valueExpectation.fulfill()
            }
        }

        let opExpectation = OperationExpectation(operations: [opA, blockOp])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(opA.isFinished)
        XCTAssertTrue(blockOp.isFinished)
    }

    func testAsyncBlockConsumerProducerOperation() {
        let opA = IntProducerOperation(intValue: 10)

        let blockOp = AsyncBlockConsumerProducerOperation<Int, Int>(producerOp: opA) { (value, block) in
            let newValue = value * 10

            DispatchQueue.global().async {
                block(newValue)
            }
        }

        XCTAssertTrue(blockOp.isAsynchronous)

        let valueExpectation = expectation(description: "Got Value")

        let opB = BlockConsumerOperation(producerOp: blockOp) { (value) in
            if value == 100 {
                valueExpectation.fulfill()
            }
        }

        let opExpectation = OperationExpectation(operations: [opA, blockOp, opB])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(opA.isFinished)
        XCTAssertTrue(blockOp.isFinished)
        XCTAssertTrue(opB.isFinished)
    }
}
