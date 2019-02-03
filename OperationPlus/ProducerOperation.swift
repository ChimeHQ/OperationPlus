//
//  ProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-01-31.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An alias to ProducerOperation
///
/// This is including for backwards compatibility. `ProducerOperation`
/// should be used for new code.
public typealias ResultOperation<T> = ProducerOperation<T>

open class ProducerOperation<T> : BaseOperation {
    public typealias ResultBlock = (T) -> Void

    public var resultCompletionBlock: ResultBlock?
    public var value: T?

    public func finish(with v: T) {
        self.value = v

        let invokeBlock = !(isCancelled || isTimedOut)

        if invokeBlock {
            resultCompletionBlock?(v)
        }

        finish()
    }
}
