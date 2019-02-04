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
}
