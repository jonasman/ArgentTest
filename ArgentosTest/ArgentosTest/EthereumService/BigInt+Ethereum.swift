//
//  BigInt+Ethereum.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 21/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import Foundation
import BigInt

class EthereumValue {
    var value: BigUInt
    
    init(value: BigUInt) {
        self.value = value
    }
    
    var wei: NSDecimalNumber {
        return NSDecimalNumber(string: value.description)
    }
    
    var gwei: NSDecimalNumber {
        wei.multiplying(byPowerOf10: -9)
    }
    
    var eth: NSDecimalNumber {
        wei.multiplying(byPowerOf10: -18)
    }
    
    var ethString: String {
        return ("\(eth)")
    }
    
    var ethStringFormatted: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        return formatter.string(from: eth)
    }
}

