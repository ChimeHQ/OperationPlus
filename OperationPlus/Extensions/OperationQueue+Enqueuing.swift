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

    public func addAsyncOperation(block: @escaping AsyncBlockOperation.CompletionHandler) {
        addOperation(AsyncBlockOperation(block: block))
    }
}
