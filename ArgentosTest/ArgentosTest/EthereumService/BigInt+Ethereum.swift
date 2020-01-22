//
//  BigInt+Ethereum.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 21/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
    /*func toWei() -> String {
        let mutiple = BigUInt(hex: "0xde0b6b3a7640000")!
        let value = self.multiplied(by: mutiple)
        return "\(value)"
    }*/
    func fromWei() -> String {
        let eighteenDecimals = "0xde0b6b3a7640000"
        let mutiple = BigUInt(hex: eighteenDecimals)!
        let (quotient, remainder) = self.quotientAndRemainder(dividingBy: mutiple)
        return "\(quotient)." + "\(remainder)".substring(to: 2)
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
}
