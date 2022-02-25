//
//  AsyncProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-01-31.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An alias to AsyncProducerOperation
///
/// This is including for backwards compatibility. `AsyncProducerOperation`
/// should be used for new code.
public typealias AsyncResultOperation<T> = AsyncProducerOperation<T>

open class AsyncProducerOperation<T> : ProducerOperation<T> {
    override open var isAsynchronous: Bool {
        return true
    }
}
