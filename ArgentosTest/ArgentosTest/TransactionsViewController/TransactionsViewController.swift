//
//  TransactionsViewController.swift
//  ArgentosTest
//
//  Created by Joao Nunes on 22/01/2020.
//  Copyright © 2020 joao. All rights reserved.
//

import UIKit
import web3

class TransactionsViewController: UITableViewController {

    var state = TransactionViewState()
    var ethereumService: EthereumService?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            ethereumService = try EthereumService()
        } catch {
            //TODO: Tell the user that there was an error and how to recover
        }
        
        getState()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return state.transactions.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let transactionCell = cell as? TransactionCell else {
            return cell
        }
        
        let event = state.transactions[indexPath.row]
        
        transactionCell.fromLabel.text = event.from.value
        transactionCell.amountLabel.text = event.value.description
        transactionCell.tokenLabel.text = event.log.address.value
        
        return transactionCell
    }
    
    
    

    func getState() {
        
        let walletAddress = "0x70ABd7F0c9Bdc109b579180B272525880Fb7E0cB"
        
        ethereumService?.getLastERC20Transactions(walletAddress: walletAddress) {
            [weak self] (result: Result<[ERC20Events.Transfer], EthereumServiceError>) in
            
            switch result {
            case .success(let events):
                DispatchQueue.main.async {
                    self?.state.transactions = events
                    self?.updateView()
                }
            case .failure(let error):
                // TODO: show the error to the user
                print(error)
                break
            }
               
        }
    }
    
    func updateView() {
        tableView.reloadData()
    }

}
