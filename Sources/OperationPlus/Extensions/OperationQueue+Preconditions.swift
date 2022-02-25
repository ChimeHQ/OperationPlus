//
//  OperationQueue+Helpers.swift
//  Operation
//
//  Created by Matt Massicotte on 11/18/17.
//  Copyright © 2017 Chime Software. All rights reserved.
//

import Foundation

extension OperationQueue {
    public static func preconditionMain() {
        if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
        }
    }

    public static func preconditionNotMain() {
        if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))
        }
    }
}
