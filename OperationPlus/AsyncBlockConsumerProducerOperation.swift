//
//  AsyncBlockConsumerProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-09-14.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An asynchronous variant of BlockConsumerProducerOperation
public class AsyncBlockConsumerProducerOperation<Input, Output>: AsyncConsumerProducerOperation<Input, Output> {
    public typealias CompletionHandler = (Input, @escaping (Output?) -> Void) -> Void

    private let block: CompletionHandler

    public init(producerOp: ProducerOperation<Input>, timeout: TimeInterval = .greatestFiniteMagnitude, block: @escaping CompletionHandler) {
        self.block = block

        super.init(producerOp: producerOp, timeout: timeout)
    }

    override open func main(with producedValue: Input) {
        block(producedValue, {(output) in
            if let o = output {
                self.finish(with: o)
            } else {
                self.finish()
            }
        })
    }
}
