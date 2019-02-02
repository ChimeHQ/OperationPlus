//
//  NeverFinishingOperation.swift
//  Operation
//
//  Created by Matt Massicotte on 2019-01-30.
//  Copyright © 2019 Chime Systems. All rights reserved.
//

import Foundation
import OperationPlus

/// A simple `Operation` that will never complete. Useful for testing
/// timeout behavior of other systems.
///
/// Warning: This operation will completely block a serial queue forever
public class NeverFinishingOperation: BaseOperation {
    public override func main() {
    }
}
