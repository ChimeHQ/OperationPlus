//
//  AsyncProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-01-31.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

open class AsyncProducerOperation<Output> : ProducerOperation<Output> {
    override open var isAsynchronous: Bool {
        return true
    }
}

public typealias AsyncResultOperation<Success, Failure: Error> = AsyncProducerOperation<Result<Success, Failure>>
