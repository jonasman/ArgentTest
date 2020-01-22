//
//  SecureEthereumKeyStorage.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 21/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import Foundation
import web3

class SecureEthereumKeyStorage: EthereumKeyStorageProtocol {
    
    func storePrivateKey(key: Data) throws -> Void {
        
    }
    
    func loadPrivateKey() throws -> Data {
        return Data()
    }
}
