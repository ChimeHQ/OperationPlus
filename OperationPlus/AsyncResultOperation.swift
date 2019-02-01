//
//  AsyncResultOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-01-31.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

open class AsyncResultOperation<T> : ResultOperation<T> {
    override open var isAsynchronous: Bool {
        return true
    }
}
