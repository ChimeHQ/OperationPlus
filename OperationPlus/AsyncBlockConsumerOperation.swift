//
//  AsyncBlockConsumerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2020-03-23.
//  Copyright © 2020 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An asynchronous variant of BlockConsumerOperation
public class AsyncBlockConsumerOperation<Input>: AsyncConsumerOperation<Input> {
    public typealias CompletionHandler = (Input, @escaping () -> Void) -> Void

    private let block: CompletionHandler

    public init(producerOp: ProducerOperation<Input>, block: @escaping CompletionHandler) {
        self.block = block

        super.init(producerOp: producerOp)
    }

    override open func main(with producedValue: Input) {
        block(producedValue, {
            self.finish()
        })
    }
}
