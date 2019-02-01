//
//  Operation+Helpers.swift
//  Operation
//
//  Created by Matt Massicotte on 1/9/18.
//  Copyright © 2018 Chime Software. All rights reserved.
//

import Foundation

extension Operation {
    public func addDependencies(_ dependencies: [Operation]) {
        for op in dependencies {
            addDependency(op)
        }
    }
}
