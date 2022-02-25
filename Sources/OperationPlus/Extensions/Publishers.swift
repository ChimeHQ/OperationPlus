import Foundation

#if canImport(Combine)
import Combine

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public extension Operation {
    func publisher() -> AnyPublisher<Void, Never> {
        return Deferred {
            Future { promise in
                self.completionBlock = {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public extension ProducerOperation {
    func outputPublisher() -> AnyPublisher<T, Never> {
        return Deferred {
            Future { block in
                self.resultCompletionBlock = { value in
                    block(.success(value))
                }
            }
        }.eraseToAnyPublisher()
    }
}

#endif
