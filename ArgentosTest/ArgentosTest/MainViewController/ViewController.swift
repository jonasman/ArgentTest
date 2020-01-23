//
//  ViewController.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 21/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import UIKit
import BigInt
import web3

class ViewController: UIViewController {

    @IBOutlet weak var balanceLabel: UILabel!
    
    var ethereumService: EthereumService?
    var state = ViewState()
    

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            ethereumService = try EthereumService()
        } catch {
            //TODO: Tell the user that there was an error and how to recover
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateState()
    }
    
    //MARK: - Logic
    
    func updateView() {
        balanceLabel.text = state.balance
    }

    func updateState() {
        
        // For a real app this must come from a storage of our own wallet address.
        let walletAddress = "0x70ABd7F0c9Bdc109b579180B272525880Fb7E0cB"
        
        ethereumService?.getWalletBalance(walletAddress: walletAddress) {
            [weak self]  (result: Result<BigUInt, EthereumServiceError>) in
            
            switch result {
                
            case .success(let balance):
                DispatchQueue.main.async {
                    self?.state.updateBalance(ETHBalance: balance)
                    self?.updateView()
                }
            case .failure(let error):
                // TODO: show the error to the user
                print(error)
                break
                
            }
        }
    }

    @IBAction func sendETH(_ sender: Any) {
        
        // For a real app this must come from a storage of our own wallet address.
        let walletAddress = EthereumAddress("0x70ABd7F0c9Bdc109b579180B272525880Fb7E0cB")
        // For a real app the address must be picked by the user via QR code, textbox or some other input method
        let toAddress = EthereumAddress.zero
        // For a real app the amount must be coming from a textbox and probably in ETH and be converted to WEI
        let amountWEI = BigUInt("10000000000000000")
        
        ethereumService?.sendETH(walletAddress: walletAddress, toAddress: toAddress, WEIamount: amountWEI) {
            (result: Result<Void, EthereumServiceError>) in
            print("Sent")
        }
        
    }
}

