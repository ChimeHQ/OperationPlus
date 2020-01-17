//
//  NeverFinishingProducerOperation.swift
//  OperationTestingPlus
//
//  Created by Matt Massicotte on 2020-01-15.
//  Copyright © 2020 Chime Systems Inc. All rights reserved.
//

import Foundation
import OperationPlus

/// A simple `ProducerOperation` that will never complete. Useful for testing
/// timeout behavior of other systems.
///
/// Warning: This operation will completely block a serial queue forever
public class NeverFinishingProducerOperation<T>: ProducerOperation<T> {
    public override func main() {
    }
}
