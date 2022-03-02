//
//  BaseOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2018-03-28.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

open class BaseOperation : Operation {
    public enum State {
        case notStarted
        case running
        case finished
    }

    private let lock: NSRecursiveLock
    private var state: State = .notStarted
    public let timeoutInterval: TimeInterval
    private var hasTimedOut: Bool = false

    public init(timeout: TimeInterval = .greatestFiniteMagnitude) {
        self.lock = NSRecursiveLock()
        self.timeoutInterval = timeout

        lock.name = "com.chimehq.Operation-Lock"

        super.init()
    }

    open func handleError(_ error: BaseOperationError) {
        fatalError(error.localizedDescription)
    }

    override open var isExecuting: Bool {
        lock.lock()
        defer { lock.unlock() }

        return state == .running
    }

    override open var isFinished: Bool {
        lock.lock()
        defer { lock.unlock() }

        return state == .finished
    }

    open var isTimedOut: Bool {
        lock.lock()
        defer { lock.unlock() }

        return hasTimedOut
    }

    private func markTimedOut() {
        lock.lock()
        defer { lock.unlock() }

        if isFinished {
            return
        }

        hasTimedOut = true
        timedOut()
    }

    /// Called when an operation times out.
    ///
    /// This is a useful hook for subclassers. By default, this will call cancel() and then finish(). If you
    /// do override this method, be sure to either call super or explicitly finish the operation.
    open func timedOut() {
        cancel()
        finish()
    }

    func beginExecution() {
        transition(to: .running)

        setupTimeout()
    }

    override open func start() {
        beginExecution()

        if checkForCancellation() {
            return
        }

        main()
    }

    override open func main() {
        // only really makes sense when subclassers override this
        finish()
    }

    override open func addDependency(_ op: Operation) {
        lock.lock()
        let invalid = state != .notStarted
        lock.unlock()

        if invalid {
            handleError(.dependencyAddedInInvalidState(op))
        }

        super.addDependency(op)
    }
}

extension BaseOperation {
    private var deadlineTime: DispatchTime {
        return DispatchTime.now() + .milliseconds(Int(timeoutInterval * 1000.0))
    }

    private func setupTimeout() {
        guard timeoutInterval < TimeInterval.greatestFiniteMagnitude else {
            return
        }

        guard !isCancelled else {
            return
        }

        DispatchQueue.global().asyncAfter(deadline: deadlineTime) { [weak self] in
            self?.markTimedOut()
        }
    }
}

extension BaseOperation {
    public func finish() {
        lock.lock()
        defer { lock.unlock() }

        // If we've timed out, it's still likely that finish
        // is going to be called again. We should be ok with that.
        if isTimedOut && isFinished {
            return
        }

        transition(to: .finished)
    }

    public func checkForCancellation() -> Bool {
        if isCancelled {
            finish()
            return true
        }

        return false
    }

    func transition(to newState: State) {
        lock.lock()
        defer { lock.unlock() }

        switch (state, newState) {
        case (.notStarted, .running):
            willChangeValue(forKey: "isExecuting")
            state = newState;
            didChangeValue(forKey: "isExecuting")
        case (.running, .finished):
            willChangeValue(forKey: "isExecuting")
            willChangeValue(forKey: "isFinished")
            state = newState;
            didChangeValue(forKey: "isFinished")
            didChangeValue(forKey: "isExecuting")
        case (_, .notStarted), (.finished, _), (.running, _), (.notStarted, _):
            handleError(.stateTransitionInvalid(newState))
        }
    }
}
