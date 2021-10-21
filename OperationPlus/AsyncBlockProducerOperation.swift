//
//  AsyncBlockProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-09-13.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An asynchronous variant of BlockProducerOperation
public class AsyncBlockProducerOperation<Output>: AsyncProducerOperation<Output> {
    public typealias CompletionHandler = (@escaping (Output?) -> Void) -> Void

    private let block: CompletionHandler

    public init(timeout: TimeInterval = .greatestFiniteMagnitude, block: @escaping CompletionHandler) {
        self.block = block

        super.init(timeout: timeout)
    }

    override open func main() {
        block({ (output) in
            if let o = output {
                self.finish(with: o)
            } else {
                self.finish()
            }
        })
    }
}
