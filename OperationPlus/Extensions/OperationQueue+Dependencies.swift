//
//  OperationQueue+Dependencies.swift
//  Operation
//
//  Created by Matt Massicotte on 2019-01-29.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

extension OperationQueue {
    public func addOperation(_ operation: Operation, dependency: Operation) {
        operation.addDependency(dependency)

        addOperation(operation)
    }

    public func addOperation(_ operation: Operation, dependencies: [Operation]) {
        operation.addDependencies(dependencies)

        addOperation(operation)
    }
}

