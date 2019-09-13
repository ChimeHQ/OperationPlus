//
//  AsyncBlockOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-01-31.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An operation for enqueuing inline work that can be completed with a callback
public class AsyncBlockOperation: AsyncOperation {
    public typealias CompletionHandler = (@escaping () -> Void) -> Void

    private let block: CompletionHandler

    public init(block: @escaping CompletionHandler) {
        self.block = block
    }

    public override func main() {
        block({
            self.finish()
        })
    }
}
