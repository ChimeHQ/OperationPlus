//
//  ConsumerOperation.swift
//  OperationPlus
//
//  Created by Matt Massicotte on 2019-09-13.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation

/// An operation that depends on and uses the value of a ProducerOperation
public typealias ConsumerOperation<Input> = ConsumerProducerOperation<Input, Void>
