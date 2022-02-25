//
//  CombineTests.swift
//  
//
//  Created by Matthew Massicotte on 2022-02-25.
//

import XCTest
import OperationTestingPlus
@testable import OperationPlus

#if canImport(Combine)
import Combine

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
class CombineTests: XCTestCase {
    var subs = Set<AnyCancellable>()

    func testOperationPublisher() {
        let op = Operation()

        let valueExpectation = expectation(description: "Got Value")
        valueExpectation.assertForOverFulfill = true

        op.publisher()
            .sink {
                valueExpectation.fulfill()
            }
            .store(in: &subs)

        let opExpectation = OperationExpectation(operations: [op])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
    }

    func testProducerPublisher() {
        let op = IntProducerOperation(intValue: 42)

        let valueExpectation = expectation(description: "Got Value")
        valueExpectation.assertForOverFulfill = true

        op.publisher()
            .sink {
                valueExpectation.fulfill()
            }
            .store(in: &subs)

        let opExpectation = OperationExpectation(operations: [op])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
        XCTAssertEqual(op.value, 42)
    }

    func testResultPublisher() throws {
        let op = IntResultProducerOperation(.success(42))

        let valueExpectation = expectation(description: "Got Value")
        valueExpectation.assertForOverFulfill = true

        op.outputPublisher()
            .flatMap { result in
                return result.publisher
            }
            .sink { error in

            } receiveValue: { value in
                valueExpectation.fulfill()
            }
            .store(in: &subs)

        let opExpectation = OperationExpectation(operations: [op])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
        XCTAssertEqual(try op.resultValue.get(), 42)
    }
}

#endif
