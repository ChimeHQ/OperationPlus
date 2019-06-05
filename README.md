[![Build Status](https://travis-ci.org/ChimeHQ/OperationPlus.svg?branch=master)](https://travis-ci.org/ChimeHQ/OperationPlus)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/OperationPlus.svg)](https://cocoapods.org/)
[![CocoaPods](https://img.shields.io/cocoapods/p/OperationPlus.svg)](https://cocoapods.org/)
![](https://img.shields.io/badge/Swift-4.2-orange.svg)

# OperationPlus

OperationPlus is a small set of NSOperation subclasses and extensions on NSOperation/NSOperationQueue. Its goal is to fill in NSOperation API's missing pieces. You don't need to learn anything new to use it.

There are a bunch of alternatives to the NSOperation model, like reactive programming. But, since Apple ships NSOperation, it gets used a lot. Once you start building real applications against it, you might find that the API is missing some important parts. OperationPlus tries to fill those in.

## Integration

Swift Package Manager:

```swift
dependencies: [
        .package(url: "https://github.com/ChimeHQ/OperationPlus.git")
]
```

Carthage:

```
github "ChimeHQ/OperationPlus"
```

CocoaPods:

```
pod 'OperationPlus'
```

## NSOperation Subclasses

 - BaseOperation: provides core functionality for easier NSOperation subclassing
 - AsyncOperation: convenience wrapper around BaseOperation for async support
 - AsyncBlockOperation: convenience class for inline async support
 - (Async)ProducerOperation: produces an output
 - (Async)ConsumerOperation: accepts an input from a ProducerOperation
 - (Async)ConsumerProducerOperation: accepst an input from a ProducerOperation and also produces an output

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
        // fail if it wasn't succesfully produced
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

op.addDependencies([opA, opB])
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

Delays:

```swift
queue.addOperation(op, afterDelay: 5.0)
```

### XCTest Support

**OperationTestingPlus** is an optional micro-framework to help make your XCTest-based tests a little nicer. When using Carthage, it is built as a static framework to help ease integration with your testing targets.

**FulfillExpectationOperation**

A simple NSOperation that will fulfill an `XCTestExpectation` when complete. Super-useful when used with dependencies on your other operations.

**NeverFinishingOperation**

A great way to test out your Operations' timeout behaviors.

**OperationExpectation**

An `XCTestExpectation` sublass to make testing async operations a little more XCTTest-like.

```swift
let op = NeverFinishingOperation()

let expectation = OperationExpectation(operation: op)
expectation.isInverted = true

wait(for: [expectation], timeout: 1.0)
```

### Suggestions or Feedback

We'd love to hear from you! Get in touch via [twitter](https://twitter.com/chimehq), an issue, or a pull request.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
