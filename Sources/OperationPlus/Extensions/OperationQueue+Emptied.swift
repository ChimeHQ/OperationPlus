//
//  OperationQueue+Emptied.swift
//  Operation
//
//  Created by Matt Massicotte on 2019-01-30.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

extension OperationQueue {
    @discardableResult
    public func currentOperationsFinished(completionBlock: @escaping () -> Void) -> Operation {
        let op = BlockOperation(block: completionBlock)

        addOperation(op, dependencies: self.operations)

        return op
    }
}
