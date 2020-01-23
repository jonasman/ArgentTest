//
//  TransferManager.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 22/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import Foundation
import web3
import BigInt

struct TransferManager {
    
    enum ContractAddress: String {
       case ropsten = "0xcdAd167a8A9EAd2DECEdA7c8cC908108b0Cc06D1"
    }
    
     struct TransferToken: ABIFunction {
        public static let name = "transferToken"
        public let gasPrice: BigUInt? = BigUInt("12000000000")
        public let gasLimit: BigUInt? = BigUInt("250000")
        public var contract: EthereumAddress
        public let from: EthereumAddress?
        
        public let wallet: EthereumAddress
        public let token: EthereumAddress
        public let to: EthereumAddress
        public let amount: BigUInt
        public let data: Data
        
        public init(contract: EthereumAddress,
                    from: EthereumAddress? = nil,
                    wallet: EthereumAddress,
                    token: EthereumAddress,
                    to: EthereumAddress,
                    amount: BigUInt,
                    data: Data) {
            self.contract = contract
            self.from = from
            
            self.wallet = wallet
            self.token = token
            self.to = to
            self.amount = amount
            self.data = data
        }
        
        public func encode(to encoder: ABIFunctionEncoder) throws {
            try encoder.encode(wallet)
            try encoder.encode(token)
            try encoder.encode(to)
            try encoder.encode(amount)
            try encoder.encode(data)
        }
    }

}
