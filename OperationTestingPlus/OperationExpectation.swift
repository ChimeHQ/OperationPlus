//
//  OperationExpectation.swift
//  Operation
//
//  Created by Matt Massicotte on 2019-01-29.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation
import class XCTest.XCTestExpectation


/// An expectation that is fulfilled when an operation
/// has finished execution.
public class OperationExpectation: XCTestExpectation {
    public var queue: OperationQueue


    /// Initializes the expectation with an operation and an optional queue.
    ///
    /// - Parameters:
    ///   - operation: This expectation is fulfilled when this operation completes
    ///   - queue: The queue to use for the operation (optional)
    public init(operation: Operation, queue: OperationQueue = OperationQueue()) {
        self.queue = queue

        super.init(description: "Operation Expectation")

        let expectationOp = FulfillExpectationOperation(expectation: self)
        expectationOp.addDependency(operation)

        queue.addOperations([operation, expectationOp], waitUntilFinished: false)
    }

    deinit {
        queue.cancelAllOperations()
    }
}
