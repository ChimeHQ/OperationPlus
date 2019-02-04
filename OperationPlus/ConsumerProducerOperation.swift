//
//  ConsumerProducerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-02-02.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An operation that depends on and uses the value of a ProducerOperation, and also
/// itself produces a value
open class ConsumerProducerOperation<Input, Output>: ProducerOperation<Output> {
    private let producerOp: ProducerOperation<Input>

    /// Initializes the operation
    ///
    /// - Parameters:
    ///   - producerOp: this will become a dependency of the instance
    ///   - timeout: an optional timeout that will automatically finish the operation
    public init(producerOp: ProducerOperation<Input>, timeout: TimeInterval = .greatestFiniteMagnitude) {
        self.producerOp = producerOp

        super.init(timeout: timeout)

        addDependency(producerOp)
    }

    /// The value of the ProducerOperation
    ///
    /// This value can be null regardless of the generic type of ProducerOperation. This
    /// is because that operation might never complete, never start, or could
    /// timeout.
    public var producerValue: Input? {
        return producerOp.value
    }

    open override func main() {
        guard let value = producerValue else {
            finish()
            return
        }

        main(with: value)
    }

    /// A main entry point with a non-optional value
    ///
    /// This method is only invoked if the ProducerOperation
    /// dependency successfully produces a value. Otherwise,
    /// this operation will call finish() directly.
    ///
    /// - Parameter value: The ProducerOperation's value, if non-optional
    open func main(with value: Input) {
        finish()
    }
}

/// An asynchronous variant of ConsumerProducerOperation
open class AsyncConsumerProducerOperation<Input, Output>: ConsumerProducerOperation<Input, Output> {
    override open var isAsynchronous: Bool {
        return true
    }
}

/// An operation that depends on and uses the value of a ProducerOperation
public typealias ConsumerOperation<Input> = ConsumerProducerOperation<Input, Void>

/// An asynchronous variant of ConsumerOperation
open class AsyncConsumerOperation<Input>: ConsumerOperation<Input> {
    override open var isAsynchronous: Bool {
        return true
    }
}
