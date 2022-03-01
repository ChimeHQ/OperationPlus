//
//  ProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-01-31.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

open class ProducerOperation<Output> : BaseOperation {
    public enum OutputCompletionBlockBehavior {
        case onCompletionOnly
        case onTimeOut(Output)
    }

    public typealias OutputHandler = (Output) -> Void

    public var outputCompletionBlock: OutputHandler?
    public var value: Output?
    public var outputCompletionBlockBehavior = OutputCompletionBlockBehavior.onCompletionOnly

    /// Block to return a cached value
    ///
    /// This block is run before main executed. If it
    /// returns a non-nil value, that value is used instead
    /// of executing the main body. This is useful for caching
    /// the result in external storage.
    public var readCacheBlock: (() -> Output?)?

    /// Block to write back a cached value
    ///
    /// This block is run after the operation has successfully
    /// produced a value. It can be used to write the value
    /// out to external storage.
    public var writeCacheBlock: ((Output) -> Void)?

    public func finish(with v: Output) {
        self.value = v
        writeCacheBlock?(v)

        switch (outputCompletionBlockBehavior, isCancelled, isTimedOut) {
        case (_, false, false):
            outputCompletionBlock?(v)
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

        switch (outputCompletionBlockBehavior, isCancelled, isTimedOut) {
        case (.onTimeOut(let v), _, true):
            self.value = v
            outputCompletionBlock?(v)
        default:
            break
        }
    }
}

public typealias ResultOperation<Success, Failure: Error> = ProducerOperation<Result<Success, Failure>>
