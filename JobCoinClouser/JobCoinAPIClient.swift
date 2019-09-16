//
//  JobCoinAPIClient.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/13/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import Foundation
import Alamofire

class JobCoinAPIClient : NSObject {
    
    let userInfoURLPrefix = "http://jobcoin.gemini.com/trout/api/addresses/"
    let sendCoinURL = "http://jobcoin.gemini.com/trout/api/transactions"
    
    func getInfoForAddress(address: String, queue: DispatchQueue, success:((_ addressInfo: [String : Any]) -> ())?, failure: ((_ error: Error?) -> ())?) {
        
        let endpoint = userInfoURLPrefix + address
        let request = Alamofire.request(endpoint)
        request.responseJSON(queue: queue, options: []) { (response) in
            if response.result.isFailure {
                failure?(response.error)
            } else {
                if let userInfo = response.value as? [String : Any] {
                    success?(userInfo)
                } else {
                    failure?(nil)
                }
            }
        }
    }
    
    func sendJobCoin(fromAddress: String, toAddress: String, amount: String, success: (() -> ())?, failure: ((_ addressError: String?, _ amountError: String?) -> ())?) {
        
        let request = Alamofire.request(sendCoinURL, method: .post, parameters: ["fromAddress": fromAddress, "toAddress" : toAddress, "amount" : amount], encoding: URLEncoding.default, headers: nil)
        request.responseJSON { (response) in
          
            if let userInfo = response.value as? [String : Any] {
                if let _ = userInfo["status"] {
                    success?()
                } else if let errorMessage = userInfo["error"] as? [String : Any] {
                    let amountError = errorMessage["amount"] as? String
                    let addressError = errorMessage["toAddress"] as? String
                    failure?(addressError, amountError)
                } else {
                    failure?(nil, nil)
                }
            } else {
                failure?(nil, nil)
            }
        }
        
    }
    
}
