import Foundation

#if canImport(Combine)
import Combine

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 6.0, *)
public extension ProducerOperation {
    func publisher() -> AnyPublisher<T, Never> {
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
