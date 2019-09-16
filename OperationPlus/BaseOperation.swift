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
        case timedOut
    }

    private let lock: NSRecursiveLock
    private var state: State = .notStarted
    public let timeoutInterval: TimeInterval

    public init(timeout: TimeInterval = .greatestFiniteMagnitude) {
        self.lock = NSRecursiveLock()
        self.timeoutInterval = timeout

        lock.name = "com.chimehq.Operation-Lock"

        super.init()
    }

    open func handleError(_ error: BaseOperationError) {
        fatalError(error.localizedDescription)
    }

    override open var isConcurrent: Bool {
        return isAsynchronous
    }

    override open var isExecuting: Bool {
        lock.lock()
        defer { lock.unlock() }

        return state == .running
    }

    override open var isFinished: Bool {
        lock.lock()
        defer { lock.unlock() }

        return state == .finished || state == .timedOut
    }

    open func timedOut() {
        transition(to: .timedOut)
    }

    func prepareForMain() {
        transition(to: .running)

        setupTimeout()
    }

    override open func start() {
        if checkForCancellation() {
            return
        }

        prepareForMain()

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
    public var isTimedOut: Bool {
        lock.lock()
        defer { lock.unlock() }

        return state == .timedOut
    }

    private var deadlineTime: DispatchTime {
        return DispatchTime.now() + .seconds(Int(timeoutInterval))
    }

    private func setupTimeout() {
        guard timeoutInterval < TimeInterval.greatestFiniteMagnitude else {
            return
        }

        DispatchQueue.global().asyncAfter(deadline: deadlineTime) { [weak self] in
            guard let op = self else {
                return
            }

            op.timedOut()
        }
    }
}

extension BaseOperation {
    public func finish() {
        transition(to: .finished)
    }

    public func checkForCancellation() -> Bool {
        if isCancelled {
            finish()
            return true
        }

        // this is just a guard to protect against
        // accidental early finishes
        if isFinished {
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
        case (.running, .finished), (.running, .timedOut):
            willChangeValue(forKey: "isExecuting")
            willChangeValue(forKey: "isFinished")
            state = newState;
            didChangeValue(forKey: "isFinished")
            didChangeValue(forKey: "isExecuting")
        case (.finished, .timedOut), (.timedOut, .finished):
            break
        case (_, .notStarted):
            fallthrough
        case (.finished, _), (.timedOut, _), (.running, _), (.notStarted, _):
            handleError(.stateTransitionInvalid(newState))
        }
    }
}
