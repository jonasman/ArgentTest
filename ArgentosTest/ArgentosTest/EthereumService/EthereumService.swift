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
    
    let keyStorage: EthereumKeyLocalStorage //TODO: replace with SecureEthereumKeyStorage
    var account: EthereumAccount? = nil
    let client: EthereumClient
    
    init() throws {
        
        keyStorage = EthereumKeyLocalStorage()
        guard let privateKey = "0xec983791a21bea916170ee0aead71ab95c13280656e93ea4124c447bbd9a24a2".web3.hexData else {
            throw EthereumServiceError.web3FailedToConvertPrivateKey
        }

        do {
            // Lets convert EthereumKeyStorage errors into EthereumService errors for isolation
            try keyStorage.storePrivateKey(key: privateKey)
        } catch  EthereumKeyStorageError.notFound {
            throw EthereumServiceError.keyStoreError
        } catch EthereumKeyStorageError.failedToSave {
            throw EthereumServiceError.keyStoreError
        } catch EthereumKeyStorageError.failedToLoad {
            throw EthereumServiceError.keyStoreError
        }
        
        do {
            
            // Lets convert EthereumAccount errors into EthereumService errors for isolation
            account = try EthereumAccount(keyStorage: keyStorage)
            print(account?.address)
            
        } catch EthereumAccountError.createAccountError {
            throw EthereumServiceError.createAccountError
        } catch EthereumAccountError.loadAccountError {
            throw EthereumServiceError.loadAccountError
        } catch EthereumAccountError.signError {
            throw EthereumServiceError.signError
        }
        
        guard let clientUrl = URL(string: "https://ropsten.infura.io/v3/735489d9f846491faae7a31e1862d24b") else {
            throw EthereumServiceError.clientURLError
        }
        
        client = EthereumClient(url: clientUrl)
    }
    
    
    // MARK: - Get Wallet Balance
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
    func sendETH(completionHandler: @escaping (Result<Void, EthereumServiceError>) -> ()) {
        
        let contractAddress = EthereumAddress("0xcdAd167a8A9EAd2DECEdA7c8cC908108b0Cc06D1")
        let walletAddress = EthereumAddress("0x70ABd7F0c9Bdc109b579180B272525880Fb7E0cB")
        let tokenAddress = EthereumAddress("0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE")
        let toAddress = EthereumAddress.zero
        let amountWEI = BigUInt("10000000000000000")
        
        
        let function = TransferManager.TransferToken(contract: contractAddress, wallet: walletAddress, token: tokenAddress, to: toAddress, amount: amountWEI, data: Data())
        
        guard let transaction = try? function.transaction(),
            let account = account else {
            completionHandler(.failure(EthereumServiceError.failedToSendEth))
            return
        }

        client.eth_sendRawTransaction(transaction, withAccount: account) {
            (error, txHash) in
            print("TX Hash: \(txHash)")
        }
        
        
        
    }
    
    // MARK: - Get Wallet Transactions
    func getLastTransactions(walletAddress: String, completionHandler: @escaping (Result<[ERC20Events.Transfer], EthereumServiceError>) -> ()) {
        
        let address = EthereumAddress(walletAddress)
        
        ERC20(client: client).transferEventsTo(recipient: address, fromBlock: .Earliest, toBlock: .Latest) { (error: Error?, events: [ERC20Events.Transfer]?) in
            if let events = events {
                completionHandler(Result<[ERC20Events.Transfer], EthereumServiceError>.success(events))
            } else {
                completionHandler(Result<[ERC20Events.Transfer], EthereumServiceError>.failure(EthereumServiceError.failedToGetLastTransactions))
            }
        }
        /*
        client.eth_getLogs(addresses: [walletAddress], orTopics: nil, fromBlock: .Earliest, toBlock: .Latest) {
            (error: EthereumClientError?, log: [EthereumLog]?) in
            
            if let log = log {
                completionHandler(Result<[EthereumLog], EthereumServiceError>.success(log))
            } else {
                completionHandler(Result<[EthereumLog], EthereumServiceError>.failure(EthereumServiceError.failedToGetLastTransactions))
            }
            
            
        }*/
        
    }
}
