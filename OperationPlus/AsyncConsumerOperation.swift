//
//  AsyncConsumerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-09-13.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An asynchronous variant of ConsumerOperation
open class AsyncConsumerOperation<Input>: ConsumerOperation<Input> {
    override public var isAsynchronous: Bool {
        return true
    }
}
