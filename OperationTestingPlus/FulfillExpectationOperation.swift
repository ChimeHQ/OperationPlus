//
//  FulfillExpectationOperation.swift
//  Operation
//
//  Created by Matt Massicotte on 2019-01-29.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import XCTest

public class FulfillExpectationOperation: Operation {
    private let expectation: XCTestExpectation

    public init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    public override func main() {
        expectation.fulfill()
    }
}
