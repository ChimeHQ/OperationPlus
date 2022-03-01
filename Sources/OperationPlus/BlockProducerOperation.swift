//
//  BlockProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-09-13.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// A block-based version of ProducerOperation
public class BlockProducerOperation<Output>: ProducerOperation<Output> {
    private let block: () -> Output?

    public init(timeout: TimeInterval = .greatestFiniteMagnitude, block: @escaping () -> Output?) {
        self.block = block

        super.init(timeout: timeout)
    }

    override open func main() {
        if let o = block() {
            self.finish(with: o)
        } else {
            self.finish()
        }
    }
}

public typealias BlockResultOperation<Success, Failure: Error> = BlockProducerOperation<Result<Success, Failure>>
