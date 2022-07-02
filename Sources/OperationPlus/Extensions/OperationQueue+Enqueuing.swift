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

extension OperationQueue {
    /// Adds the specified operation to the queue after a delay.
    ///
    /// This method schedules an `addOperation` call after the specified delay.
    ///
    /// - Parameter op: The operation to be added to the queue.
    /// - Parameter delay: The amount of time to wait before scheduling op.
    public func addOperation(_ op: Operation, afterDelay delay: TimeInterval) {
        let deadlineTime = DispatchTime.now() + delay

        DispatchQueue.global().asyncAfter(deadline: deadlineTime) {
            self.addOperation(op)
        }
    }

    /// Invokes the block on the queue after a delay.
    ///
    /// This method schedules an `addOperation` call after the specified delay.
    ///
    /// - Parameter delay: The amount of time to wait before scheduling op.
    /// - Parameter block: The block to be invoked on the queue.
    public func addOperation(afterDelay delay: TimeInterval, block: @escaping () -> Void) {
        addOperation(BlockOperation(block: block), afterDelay: delay)
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension OperationQueue {
    /// Adds the specified async operation to the queue.
    ///
    /// It's worth careful considering the priority used for operations excuted this
    /// way. `OperationQueue` and `Task` may not cooperate nicely, and prioity inversion
    /// could be possible.
    ///
    /// - Parameter block: The async operation to be added to the queue.
    public func addOperation(block: @Sendable @escaping () async -> Void) {
        let op = AsyncBlockOperation { opBlock in
            Task.detached {
                await block()

                opBlock()
            }
        }

        addOperation(op)
    }

    /// Adds the specified async operation to the queue and returns its result.
    ///
    /// This function behaves just like the async version of addOperation, but can
    /// return a result value.
    ///
    /// - Parameter block: The async operation to be added to the queue.
    public func addResultOperation<Success>(block: @Sendable @escaping () async throws -> Success) async throws -> Success {
        return try await withCheckedThrowingContinuation({ continuation in
            addOperation {
                do {
                    let value = try await block()

                    continuation.resume(returning: value)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        })
    }
}
