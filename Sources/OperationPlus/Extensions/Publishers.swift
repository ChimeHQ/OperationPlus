import Foundation

#if canImport(Combine)
import Combine

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public extension Operation {
    /// A Combine publisher that produces one event when the operation finishes
    var publisher: AnyPublisher<Void, Never> {
        return Future { promise in
            self.completionBlock = {
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public extension ProducerOperation {
    /// A Combine publisher that produces one event with the operation's result when it finishes
    var outputPublisher: AnyPublisher<Output, Never> {
        return Future { promise in
            self.outputCompletionBlock = { value in
                promise(.success(value))
            }
        }.eraseToAnyPublisher()
    }
}

/// A `ProducerOperation` subclass takes a publisher. When executed, it creates a subscription and outputs the results.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public class PublisherOperation<Output, Failure: Error>: AsyncProducerOperation<Result<Output, Failure>> {
    public typealias Publisher = AnyPublisher<Output, Failure>

    private var cancellable: AnyCancellable?
    private let chain: Publisher

    public init(publisher: Publisher, timeout: TimeInterval = .greatestFiniteMagnitude) {
        self.chain = publisher

        super.init(timeout: timeout)
    }

    public override func main() {
        self.cancellable = chain.sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .failure(let error):
                self?.finish(with: .failure(error))
            case .finished:
                if self?.isFinished == false {
                    self?.finish()
                }
            }
        }, receiveValue: { [weak self] output in
            self?.finish(with: .success(output))
        })
    }

    override public func cancel() {
        self.cancellable = nil
        super.cancel()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public extension Publisher {
    /// Creates an Operation which subscribes to the publisher when executed
    func operation() -> PublisherOperation<Output, Failure> {
        return PublisherOperation(publisher: self.eraseToAnyPublisher())
    }

    /// Subscribes and runs a publisher on a queue, producing
    /// a new publisher with the results of that operation
    ///
    /// Using `receive(on:)` or `subscribe(on:)` with the same queue
    /// argument **before** this call in a chain will cause a deadlock
    /// if that queue's maxConcurrentOperations count is one.
    func execute(on queue: OperationQueue) -> AnyPublisher<Output, Failure> {
        let op = operation()

        queue.addOperation(op)

        return Future { promise in
            op.outputCompletionBlock = promise
        }.eraseToAnyPublisher()
    }
}

#endif
