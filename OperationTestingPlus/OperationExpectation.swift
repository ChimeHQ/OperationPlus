//
//  OperationExpectation.swift
//  Operation
//
//  Created by Matt Massicotte on 2019-01-29.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation
import class XCTest.XCTestExpectation

public class OperationExpectation: XCTestExpectation {
    public var queue: OperationQueue

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
