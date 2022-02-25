//
//  AsyncConsumerProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-09-13.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An asynchronous variant of ConsumerProducerOperation
open class AsyncConsumerProducerOperation<Input, Output>: ConsumerProducerOperation<Input, Output> {
    override open var isAsynchronous: Bool {
        return true
    }
}
