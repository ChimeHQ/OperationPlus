//
//  AsyncBlockOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-01-31.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

public class AsyncBlockOperation: AsyncOperation {
    private let block: (@escaping () -> Void) -> Void

    public init(block: @escaping (@escaping () -> Void) -> Void) {
        self.block = block
    }

    public override func main() {
        block({
            self.finish()
        })
    }
}
