//
//  BlockConsumerProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-09-14.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// A block-based version of ConsumerProducerOperation
public class BlockConsumerProducerOperation<Input, Output>: ConsumerProducerOperation<Input, Output> {
    public typealias Block = (Input) -> Output?

    private let block: Block

    public init(producerOp: ProducerOperation<Input>, block: @escaping Block) {
        self.block = block

        super.init(producerOp: producerOp)
    }

    override open func main(with producedValue: Input) {
        if let o = block(producedValue) {
            self.finish(with: o)
        } else {
            self.finish()
        }
    }
}
