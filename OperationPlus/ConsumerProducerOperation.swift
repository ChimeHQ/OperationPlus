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
        guard let producedValue = producerValue else {
            finish()
            return
        }

        main(with: producedValue)
    }

    /// A main entry point with a non-optional value
    ///
    /// This method is only invoked if the ProducerOperation
    /// dependency successfully produces a non-nil value. Otherwise,
    /// this operation will call finish() directly.
    ///
    /// This behavior is particularly useful for short-circuiting
    /// downstream work that doesn't need to happen if a dependency fails
    /// to produce a value.
    ///
    /// - Parameter producedValue: The ProducerOperation's value, if non-optional
    open func main(with producedValue: Input) {
        finish()
    }
}
