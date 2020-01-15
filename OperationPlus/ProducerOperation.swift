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
    public enum ResultCompletionBlockBehavior {
        case onCompletionOnly
        case onTimeOut(T)
    }

    public typealias ResultBlock = (T) -> Void

    public var resultCompletionBlock: ResultBlock?
    public var value: T?
    public var resultCompletionBlockBehavior = ResultCompletionBlockBehavior.onCompletionOnly

    /// Block to return a cached value
    ///
    /// This block is run before main executed. If it
    /// returns a non-nil value, that value is used instead
    /// of executing the main body. This is useful for caching
    /// the result in external storage.
    public var readCacheBlock: (() -> T?)?

    /// Block to write back a cached value
    ///
    /// This block is run after the operation has successfully
    /// produced a value. It can be used to write the value
    /// out to external storage.
    public var writeCacheBlock: ((T) -> Void)?

    public func finish(with v: T) {
        self.value = v
        writeCacheBlock?(v)

        switch (resultCompletionBlockBehavior, isCancelled, isTimedOut) {
        case (_, false, false):
            resultCompletionBlock?(v)
        case (_, _, true):
            return // do not call finish in this case
        default:
            break
        }

        finish()
    }

    override open func start() {
        beginExecution()

        if checkForCancellation() {
            return
        }

        if let v = readCacheBlock?() {
            self.finish(with: v)
            return
        }

        main()
    }

    override open func timedOut() {
        super.timedOut()

        switch (resultCompletionBlockBehavior, isCancelled, isTimedOut) {
        case (.onTimeOut(let v), _, true):
            self.value = v
            resultCompletionBlock?(v)
        default:
            break
        }
    }
}
