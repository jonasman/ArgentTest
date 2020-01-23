//
//  SecureEthereumKeyStorage.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 21/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import Foundation
import web3
import KeychainAccess

class SecureEthereumKeyStorage: EthereumKeyStorageProtocol {
    
    let keychain: Keychain
    static let privateKey = "privateKey"
    
    init() {
        keychain = Keychain(service: "ArgentWallet")
    }
    
    func storePrivateKey(key: Data) throws -> Void {
        keychain[data: SecureEthereumKeyStorage.privateKey] = key
    }
    
    func loadPrivateKey() throws -> Data {
        if let key = keychain[data: SecureEthereumKeyStorage.privateKey] {
            return key
        } else {
            throw EthereumKeyStorageError.failedToLoad
        }
    }
}
