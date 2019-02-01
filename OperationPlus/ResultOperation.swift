//
//  ResultOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-01-31.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

open class ResultOperation<T> : BaseOperation {
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
