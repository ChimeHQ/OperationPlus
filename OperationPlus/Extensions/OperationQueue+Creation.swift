//
//  OperationQueue+Creation.swift
//  Operation
//
//  Created by Matt Massicotte on 2019-01-29.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation

extension OperationQueue {
    public convenience init(name: String, maxConcurrentOperations count: Int = OperationQueue.defaultMaxConcurrentOperationCount) {
        self.init()

        self.name = name
        self.maxConcurrentOperationCount = count
    }
}

extension OperationQueue {
    public static func serialQueue() -> OperationQueue {
        let queue = OperationQueue()

        queue.maxConcurrentOperationCount = 1

        return queue
    }

    public static func serialQueue(named name: String) -> OperationQueue {
        return OperationQueue(name: name, maxConcurrentOperations: 1)
    }
}
