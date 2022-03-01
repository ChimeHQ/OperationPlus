//
//  BaseOperationError.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-02-03.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation


/// The possible error states for a BaseOperation
///
/// - dependencyAddedInInvalidState: The dependeny relationship cannot be
/// enforced at this point in the operation's lifecycle
/// - stateTransitionInvalid: A transition has been triggered that does not
/// make sense. This represents a programming error.
public enum BaseOperationError: Error {
    case dependencyAddedInInvalidState(Operation)
    case stateTransitionInvalid(BaseOperation.State)
    case timedOut
}

extension BaseOperationError: Equatable {
}
