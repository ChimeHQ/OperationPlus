//
//  BlockConsumerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2020-03-23.
//  Copyright © 2020 Chime Systems Inc. All rights reserved.
//

import Foundation

/// A block-based version of ConsumerOperation
public class BlockConsumerOperation<Input>: ConsumerOperation<Input> {
    private let block: (Input) -> Void

    public init(producerOp: ProducerOperation<Input>, timeout: TimeInterval = .greatestFiniteMagnitude, block: @escaping (Input) -> Void) {
        self.block = block

        super.init(producerOp: producerOp, timeout: timeout)
    }

    override open func main(with producedValue: Input) {
        block(producedValue)

        self.finish()
    }
}
