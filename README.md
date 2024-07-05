<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]

</div>

# OperationPlus

OperationPlus is a set of `NSOperation` subclasses and extensions on `NSOperation`/`NSOperationQueue`. Its goal is to fill in the API's missing pieces. You don't need to learn anything new to use it.

NSOperation has been around for a long time, and there are now two potential first-party alternatives, Combine and Swift concurrency. OperationPlus includes some facilities to help Combine and NSOperation interoperate conveniently.

## Integration

Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/ChimeHQ/OperationPlus.git")
]
```

## NSOperation Subclasses

 - `BaseOperation`: provides core functionality for easier `NSOperation` subclassing
 - `AsyncOperation`: convenience wrapper around `BaseOperation` for async support
 - `AsyncBlockOperation`: convenience class for inline async support
 - `(Async)ProducerOperation`: produces an output
 - `(Async)ConsumerOperation`: accepts an input from a `ProducerOperation`
 - `(Async)ConsumerProducerOperation`: accepts an input from a `ProducerOperation` and also produces an output

**BaseOperation**

This is a simple `NSOperation` subclass built for easier extensibility. It features:

 - Thread-safety
 - Timeout support
 - Easier cancellation handling
 - Stricter state checking
 - Built-in asynchrous support
 - Straight-foward customization

```swift
let a = BaseOperation(timeout: 5.0)

// NSOperation will happily allow you do this even
// if `a` has finished. `BaseOperation` will not.
a.addDependency(another)

// ...
public override func main() {
    // This will return true if your operation is cancelled, timed out,
    // or prematurely finished. ProducerOperation subclass state will be
    // handled correctly as well.
    if self.checkForCancellation() {
        return
    }
}
// ...
```

**AsyncOperation**

A `BaseOperation` subclass that can be used for your asynchronous operations. These are any operations that need to extend their lifetime past the `main` method.

```swift
import Foundation
import OperationPlus

class MyAsyncOperation: AsyncOperation {
    public override func main() {
        DispatchQueue.global().async {
            if self.checkForCancellation() {
                return
            }

            // do stuff

            self.finish()
        }
    }
}
```

There's also nothing special about this class at all -- it's there just for convenience. If you want, you can just subclass `BaseOperation` directly and override one method.

```swift
import Foundation
import OperationPlus

class MyAsyncOperation: BaseOperation {
    override open var isAsynchronous: Bool {
        return true
    }
}
```

**ProducerOperation**

A `BaseOperation` subclass that yields a value. Includes a completion handler to access the value.

```swift
import Foundation
import OperationPlus

class MyValueOperation: ProducerOperation<Int> {
    public override func main() {
        // do your computation

        self.finish(with: 42)
    }
}

// ...

let op = MyValueOperation()

op.resultCompletionBlock = { (value) in
    // use value here
}
```

**AsyncProducerOperation**

A variant of `ProducerOperation` that may produce a value after the `main` method has completed executing.

```swift
import Foundation
import OperationPlus

class MyAsyncOperation: AsyncProducerOperation<Int> {
    public override func main() {
        DispatchQueue.global().async {
            if self.checkForCancellation() {
                return
            }

            // do stuff

            self.finish(with: 42)
        }
    }
}
```

**ConsumerOperation** and **AsyncConsumerOperation**

A `BaseOperation` sublass that accepts the input of a `ProducerOperation`.

```swift
import Foundation
import OperationPlus

class MyConsumerOperation: ConsumerOperation<Int> {
    override func main() {
        guard let value = producerValue else {
            // handle failure in some way
        }
    }
    
    override func main(with value: Int) {
        // make use of value here, or automatically
        // fail if it wasn't successfully produced
    }
}

let op = MyConsumerOperation(producerOp: myIntProducerOperation)
```

**AsyncBlockOperation**

A play on `NSBlockOperation`, but makes it possible to support asynchronous completion without making an `Operation` subclass. Great for quick, inline work.

```swift
let op = AsyncBlockOperation { (completionBlock) in
    DispatchQueue.global().async {
        // do some async work here, just be certain to call
        // the completionBlock when done
        completionBlock()
    }
}
```

## NSOperation/NSOperationQueue Extensions

Queue creation conveniences:

```swift
let a = OperationQueue(name: "myqueue")
let b = OperationQueue(name: "myqueue", maxConcurrentOperations: 1)
let c = OperationQueue.serialQueue()
let d = OperationQueue.serialQueue(named: "myqueue")
```

Enforcing runtime constraints on queue execution:

```swift
OperationQueue.preconditionMain()
OperationQueue.preconditionNotMain()
```

Consise dependencies:

```swift
queue.addOperation(op, dependency: opA)
queue.addOperation(op, dependencies: [opA, opB])
queue.addOperation(op, dependencies: Set([opA, opB]))

op.addDependencies([opA, opB])
op.addDependencies(Set([opA, opB]))
```

Queueing work when a queue's current operations are complete:

```swift
queue.currentOperationsFinished {
  print("all pending ops done")
}
```

Convenient inline functions:

```swift
queue.addAsyncOperation { (completionHandler) in
    DispatchQueue.global().async {
        // do some async work
        completionHandler()
    }
}
```

Async integration:

```swift
queue.addOperation {
    await asyncFunction1()
    await asyncFunction2()
}

let value = try await queue.addResultOperation {
    try await asyncValue()
}
```

Delays:

```swift
queue.addOperation(op, afterDelay: 5.0)
queue.addOperation(afterDelay: 5.0) {
  // work
}
```

### Combine Integration

**PublisherOperation**

This `ProducerOperation` subclass takes a publisher. When executed, it creates a subscription and outputs the results.

```swift
op.publisher() // AnyPublisher<Void, Never>

producerOp.outputPublisher() // AnyPublisher<Output, Never>
```

```swift
publisher.operation() // PublisherOperation
publisher.execute(on: queue) // subscribes and executes chain on queue and returns a publisher for result
```

### XCTest Support

**OperationTestingPlus** is an optional micro-framework to help make your XCTest-based tests a little nicer. When using Carthage, it is built as a static framework to help ease integration with your testing targets.

**FulfillExpectationOperation**

A simple NSOperation that will fulfill an `XCTestExpectation` when complete. Super-useful when used with dependencies on your other operations.

**NeverFinishingOperation**

A great way to test out your Operations' timeout behaviors.

**OperationExpectation**

An `XCTestExpectation` sublass to make testing async operations a little more XCTest-like.

```swift
let op = NeverFinishingOperation()

let expectation = OperationExpectation(operation: op)
expectation.isInverted = true

wait(for: [expectation], timeout: 1.0)
```

### Suggestions or Feedback

We'd love to hear from you! Get in touch via an issue or pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[build status]: https://github.com/ChimeHQ/OperationPlus/actions
[build status badge]: https://github.com/ChimeHQ/OperationPlus/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/ChimeHQ/OperationPlus
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FOperationPlus%2Fbadge%3Ftype%3Dplatforms
