//
//  OperationQueue+Enqueuing.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-02-02.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

extension OperationQueue {

    /// Adds the specified operations to the queue.
    ///
    /// This method is just a wrapper for calling `addOperations(ops, waitUntilFinished: false)`
    ///
    /// - Parameter ops: The operations to be added to the queue.
    public func addOperations(_ ops: [Operation]) {
        addOperations(ops, waitUntilFinished: false)
    }

    /// Adds the specified operation to the queue.
    ///
    /// This method is a convenience wrapper around `AsyncBlockOperation`. Note that
    /// the completion block **must** be invoked when the async work has been completed.
    ///
    /// - Warning: Failure to invoke the completion block will prevent the queue from
    /// processing more operations.
    ///
    /// - Parameter block: The async operation to be added to the queue.
    public func addAsyncOperation(block: @escaping AsyncBlockOperation.CompletionHandler) {
        addOperation(AsyncBlockOperation(block: block))
    }
}
