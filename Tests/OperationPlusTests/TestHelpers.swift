//
//  TestHelpers.swift
//  OperationPlusTests
//
//  Created by Matt Massicotte on 2019-02-04.
//  Copyright © 2019 Chime Systems Inc. All rights reserved.
//

import Foundation
import OperationPlus

class IntProducerOperation: ProducerOperation<Int> {
    let intValue: Int?

    init(intValue: Int?) {
        self.intValue = intValue
    }

    override func main() {
        if let v = intValue {
            finish(with: v)
        } else {
            finish()
        }
    }
}

class IntToBoolOperation: ConsumerProducerOperation<Int, Bool> {
    override func main(with producedValue: Int) {
        finish(with: producedValue == 42)
    }
}

typealias BoolConsumerOperation = ConsumerOperation<Bool>
typealias IntConsumerOperation = ConsumerOperation<Int>

class IntResultProducerOperation: ProducerOperation<Result<Int, Error>> {
    let resultValue: Result<Int, Error>

    init(_ value: Result<Int, Error>) {
        self.resultValue = value
    }

    override func main() {
        self.finish(with: resultValue)
    }
}
