//
//  EthereumClient+Combine.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 21/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import Foundation
import Combine
import web3
import BigInt

@available(iOS 13.0, macOS 10.15, watchOS 6, tvOS 13, *)
extension EthereumClient {
    
    private func resultify<Value: Any>(subscriber: @escaping (Result<Value, EthereumClientError>) -> Void) -> (EthereumClientError?, Value?) -> () {
        
        return { (error: EthereumClientError?, value: Value?) in
            
            if let value = value {
                subscriber(.success(value))
            } else if let error = error {
                subscriber(.failure(error))
            } else {
                // TODO: Create an error
            }
            
        }
        
    }

    public func eth_getBalance(address: String, block: EthereumBlock) -> Future<BigUInt, EthereumClientError> {
        
         let future = Future<BigUInt,EthereumClientError> { (subscriber: @escaping (Result<BigUInt, EthereumClientError>) -> Void) in
            
            self.eth_getBalance(address: address, block: block, completion: self.resultify(subscriber: subscriber))
        }
        
        return future
    }
    
    
}
