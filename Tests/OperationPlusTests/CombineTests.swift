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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 7.0, *)
class CombineTests: XCTestCase {
    var subs = Set<AnyCancellable>()

    func testOperationPublisher() {
        let op = Operation()

        let valueExpectation = expectation(description: "Got Value")

        op.publisher
            .sink {
                valueExpectation.fulfill()
            }
            .store(in: &subs)

        let opExpectation = OperationExpectation(operations: [op])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
    }

    func testOutputPublisher() throws {
        let op = IntResultProducerOperation(.success(42))

        let valueExpectation = expectation(description: "Got Value")
        valueExpectation.expectedFulfillmentCount = 2

        let pub = op
            .outputPublisher
            .flatMap { result in
                return result.publisher
            }

        // create two subscribers
        pub
            .sink { error in
            } receiveValue: { value in
                valueExpectation.fulfill()
            }
            .store(in: &subs)

        pub
            .sink { error in
            } receiveValue: { value in
                valueExpectation.fulfill()
            }
            .store(in: &subs)

        let opExpectation = OperationExpectation(operations: [op])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0, enforceOrder: true)

        XCTAssertTrue(op.isFinished)
        XCTAssertEqual(try op.resultValue.get(), 42)
    }

    func testPublisherOperation() throws {
        let pub = Just(1).eraseToAnyPublisher()

        let op = PublisherOperation(publisher: pub)

        let valueExpectation = expectation(description: "Got Value")

        op.outputCompletionBlock = { value in
            valueExpectation.fulfill()
        }

        let opExpectation = OperationExpectation(operations: [op])

        wait(for: [valueExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
        XCTAssertEqual(op.value, .success(1))
    }

    func testOperationOperator() {
        let executionExpectation = expectation(description: "Execution")

        let op = Deferred {
            Future<Int, Never> { block in
                DispatchQueue.global().async {
                    executionExpectation.fulfill()
                    block(.success(42))
                }
            }
        }.operation()

        let opExpectation = OperationExpectation(operations: [op])

        wait(for: [executionExpectation, opExpectation], timeout: 1.0)

        XCTAssertTrue(op.isFinished)
        XCTAssertEqual(op.value, .success(42))
    }

    func testExecuteOnOperator() {
        let queue = OperationQueue.serialQueue()

        let startExp = expectation(description: "Starting")
        let completingExp = expectation(description: "Starting")

        let pub = Deferred {
            Future<Int, Never> { block in
                startExp.fulfill()

                DispatchQueue.global().async {
                    completingExp.fulfill()

                    block(.success(42))
                }
            }
        }
        .subscribe(on: DispatchQueue.global())
        .execute(on: queue)

        // create two subsribers
        let firstSubExp = expectation(description: "First Value")
        pub
            .receive(on: DispatchQueue.global())
            .sink { _ in
                firstSubExp.fulfill()
            }
            .store(in: &subs)

        let secondSubExp = expectation(description: "Second Value")
        pub
            .receive(on: DispatchQueue.global())
            .sink { _ in
                secondSubExp.fulfill()
            }
            .store(in: &subs)

        let nextOpExp = expectation(description: "Next Op")

        let op = Operation()

        op.completionBlock = {
            nextOpExp.fulfill()
        }

        queue.addOperation(op)

        wait(for: [startExp, completingExp, nextOpExp], timeout: 1.0, enforceOrder: true)
        wait(for: [firstSubExp, secondSubExp], timeout: 1.0)
    }
}

#endif
