//
//  EthereumService.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 21/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import Foundation
import web3
import BigInt
import Combine

enum EthereumServiceError: Error {
    case web3FailedToConvertPrivateKey
    case keyStoreError
    case clientURLError
    case createAccountError
    case loadAccountError
    case signError
    
    case failedToGetBalance
    case failedToSendEth
    case failedToGetLastTransactions
}

class EthereumService {
    
    enum InfuraURL: String {
        case ropsten = "https://ropsten.infura.io/v3/735489d9f846491faae7a31e1862d24b"
    }
    
    let keyStorage: SecureEthereumKeyStorage
    var account: EthereumAccount? = nil
    let client: EthereumClient
    
    init() throws {
        
        keyStorage = SecureEthereumKeyStorage()

        do {
            _ = try keyStorage.loadPrivateKey()   // test that we have the key stored
        } catch {
            
            do {
                // The private key should never be stored in code.
                // The private key would eventually be generated or loaded by a user and must be stored securely. A good way to do it is to store it on the keychain
                let privateKey = "0xec983791a21bea916170ee0aead71ab95c13280656e93ea4124c447bbd9a24a2".web3.hexData! // bad
                try keyStorage.storePrivateKey(key: privateKey)
            } catch {
                // Lets convert EthereumKeyStorage errors into EthereumService errors for isolation
                throw EthereumServiceError.keyStoreError
            }

        }
        
        do {
            account = try EthereumAccount(keyStorage: keyStorage)
            print("Address: \(account?.address ?? "no address")")
            
        } catch {
            // Lets convert EthereumAccount errors into EthereumService errors for isolation
            throw EthereumServiceError.signError
        }
        
        guard let clientUrl = URL(string: InfuraURL.ropsten.rawValue) else {
            throw EthereumServiceError.clientURLError
        }
        
        client = EthereumClient(url: clientUrl)
    }
    
    
    // MARK: - Get Wallet Balance
    
    /**
    Gets the balance of a wallet
    - parameters:
        - walletAddress: Wallet address
        - completionHandler: Completion handler
    */
    
    func getWalletBalance(walletAddress: String, completionHandler: @escaping (Result<BigUInt, EthereumServiceError>) -> ()){
            
        client.eth_getBalance(address: walletAddress, block: .Latest) { (error: EthereumClientError?, balance: BigUInt?) in
            
            if let balance = balance {
                completionHandler(Result<BigUInt, EthereumServiceError>.success(balance))
            } else {
                completionHandler(Result<BigUInt, EthereumServiceError>.failure(EthereumServiceError.failedToGetBalance))
            }
            
        }
    }
    
    // MARK: - Sent ETH
    /**
    Sends ETH to an address
    - parameters:
        - walletAddress: Wallet address
        - toAddress: The destination address
        - WEIamount: The amount to send in WEI
        - completionHandler: Completion handler
    */
    func sendETH(walletAddress: EthereumAddress, toAddress: EthereumAddress, WEIamount: BigUInt, completionHandler: @escaping (Result<Void, EthereumServiceError>) -> ()) {
        
        let contractAddress = EthereumAddress(TransferManager.ContractAddress.ropsten.rawValue)
        let tokenAddress = EthereumAddress("0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE")
        
        let function = TransferManager.TransferToken(contract: contractAddress, wallet: walletAddress, token: tokenAddress, to: toAddress, amount: WEIamount, data: Data())
        
        guard let transaction = try? function.transaction(),
            let account = account else {
            completionHandler(.failure(EthereumServiceError.failedToSendEth))
            return
        }

        client.eth_sendRawTransaction(transaction, withAccount: account) {
            (error, txHash) in
            print("TX Hash: \(txHash ?? " no hash")")
        }

    }
    
    // MARK: - Get Wallet Transactions
    /**
    Gets the last ERC20 transactions
    - parameters:
        - walletAddress: Wallet address
        - completionHandler: Completion handler
    */
    func getLastERC20Transactions(walletAddress: String, completionHandler: @escaping (Result<[ERC20Events.Transfer], EthereumServiceError>) -> ()) {
        
        let address = EthereumAddress(walletAddress)
        
        ERC20(client: client).transferEventsTo(recipient: address, fromBlock: .Earliest, toBlock: .Latest) {
            (error: Error?, events: [ERC20Events.Transfer]?) in
            
            if let events = events {
                completionHandler(Result<[ERC20Events.Transfer], EthereumServiceError>.success(events))
            } else {
                completionHandler(Result<[ERC20Events.Transfer], EthereumServiceError>.failure(EthereumServiceError.failedToGetLastTransactions))
            }
        }
        
    }
}
