//
//  User.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/13/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit

enum OrderType {
    case chronological
    case reverseChronological
}

class User: NSObject {
    
    let userAddress : String
    var balance : String
    var transactions : [String : Transaction]
    
    init(address: String) {
        self.userAddress = address
        self.transactions = [:]
        self.balance = "0"
        super.init()
    }
    
    public func updateWithResponse(response: [String : Any]) {
        guard let balanceResponse = (response["balance"] as? String) else { return }
        guard let transactionsResponse = response["transactions"] as? [[String : Any]] else { return }
        self.balance = balanceResponse
        for transactionResponse in transactionsResponse {
            let transaction = Transaction(response: transactionResponse, userAddress: userAddress)
            transactions.updateValue(transaction, forKey: transaction.uuid)
        }
    }
    
    public func transactionsInOrder(orderType: OrderType) -> [Transaction] {
        var transactionsValues = Array(transactions.values)
        transactionsValues.sort { (transaction1, transaction2) -> Bool in
            if let date1 = transaction1.date {
                if let date2 = transaction2.date {
                    return orderType == .chronological ? date1 < date2 : date1 > date2
                } else {
                    return true
                }
            } else {
                if let _ = transaction2.date {
                    return false
                } else {
                    return true
                }
            }
        }
        
        return transactionsValues
    }
    
    public var chartData : [(x: Date, y: Double)] {
        var data : [(x: Date, y: Double)] = []
        var runningTotal : Float = 0
        let transactionsInChrono = transactionsInOrder(orderType: .chronological)
        for transaction in transactionsInChrono {
            if transaction.toAddress == transaction.fromAddress {
                continue
            }
            if let value = Float(transaction.amount), let date = transaction.date {
                let additiveValue = transaction.type == .sent ? -value : value
                runningTotal = runningTotal + additiveValue
                let chartPoint = (x: date, y: Double(runningTotal))
                data.append(chartPoint)
            }
        }
        
        return data
    }

}

enum TransactionType {
    case sent
    case receivedFromUser
    case receivedFromCreated
}

struct Transaction {
    
    let amount : String
    let timeStamp : String
    let toAddress : String
    let fromAddress : String?
    let type : TransactionType
    let date : Date?
    let uuid : String
    
    init(response: [String : Any], userAddress: String) {
        self.amount = response["amount"] as! String
        self.timeStamp = response["timestamp"] as! String
        self.toAddress = response["toAddress"] as! String
        self.fromAddress = response["fromAddress"] as? String
        
        if let _ = fromAddress {
            type = toAddress == userAddress ? .receivedFromUser : .sent
        } else {
            type = .receivedFromCreated
        }
        
        let dateClient = DateClient()
        date = dateClient.dateFromString(string: timeStamp, format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        uuid = "\(amount)-\(toAddress)-\(timeStamp)"
    }
    
}
