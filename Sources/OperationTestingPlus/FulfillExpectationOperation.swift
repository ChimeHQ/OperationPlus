//
//  FulfillExpectationOperation.swift
//  Operation
//
//  Created by Matt Massicotte on 2019-01-29.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import XCTest

/// This Operation subclass will fulfill an `XCTestExpectation` when it
/// completes.
public class FulfillExpectationOperation: Operation {
    private let expectation: XCTestExpectation

    /// Initializer
    ///
    /// - Parameter expectation: will call `fulfill` on this instance when run
    public init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    public override func main() {
        expectation.fulfill()
    }
}
