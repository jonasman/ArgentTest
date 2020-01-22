//
//  ViewState.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 21/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import Foundation
import BigInt
import web3

class ViewState {
    private(set) var balance: String = "0 ETH"
    
    func updateBalance(ETHBalance: BigUInt) {
        balance = "\(ETHBalance.fromWei()) ETH"
    }
}


