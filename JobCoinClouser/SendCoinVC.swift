//
//  SendCoinVC.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/16/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit

class SendCoinVC: UIViewController {
    
    let addressLabel = UILabel()
    let addressTextField = UITextField()
    let amountLabel = UILabel()
    let amountTextField = UITextField()
    let sendButton = UIButton()
    let spinner = UIActivityIndicatorView()
    let addressErrorLabel = UILabel()
    let amountErrorLabel = UILabel()
    var confirmVC : SendConfirmationVC?
    
    let user : User
    let colorScheme : ColorScheme
    let apiClient : JobCoinAPIClient
    
    init(user: User, colorScheme: ColorScheme, apiClient: JobCoinAPIClient) {
        self.user = user
        self.colorScheme = colorScheme
        self.apiClient = apiClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func configureViews() {
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        addressLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        addressLabel.font = UIFont.systemFont(ofSize: 10)
        addressLabel.textColor = UIColor.darkGray
        addressLabel.text = "SEND MONEY TO:"
        
        view.addSubview(addressTextField)
        addressTextField.translatesAutoresizingMaskIntoConstraints = false
        addressTextField.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 5).isActive = true
        addressTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        addressTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        addressTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addressTextField.placeholder = "Enter recipients address"
        addressTextField.borderStyle = .roundedRect
        addressTextField.delegate = self
        addressTextField.keyboardType = .default
        addressTextField.tag = 0
        
        view.addSubview(addressErrorLabel)
        addressErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        addressErrorLabel.leftAnchor.constraint(equalTo: addressTextField.leftAnchor, constant: 0).isActive = true
        addressErrorLabel.rightAnchor.constraint(equalTo: addressTextField.rightAnchor, constant: 0).isActive = true
        addressErrorLabel.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 2).isActive = true
        addressErrorLabel.font = UIFont.systemFont(ofSize: 10)
        addressErrorLabel.textColor = UIColor.red
        addressErrorLabel.text = ""
        
        view.addSubview(amountLabel)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 25).isActive = true
        amountLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25).isActive = true
        amountLabel.font = UIFont.systemFont(ofSize: 10)
        amountLabel.textColor = UIColor.darkGray
        amountLabel.text = "IN THE AMOUNT OF:"
        
        view.addSubview(amountTextField)
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 5).isActive = true
        amountTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        amountTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        amountTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        amountTextField.placeholder = "Enter Jobcoin amount"
        amountTextField.borderStyle = .roundedRect
        amountTextField.delegate = self
        amountTextField.keyboardType = .decimalPad
        amountTextField.tag = 1
        
        view.addSubview(amountErrorLabel)
        amountErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        amountErrorLabel.leftAnchor.constraint(equalTo: amountTextField.leftAnchor, constant: 0).isActive = true
        amountErrorLabel.rightAnchor.constraint(equalTo: amountTextField.rightAnchor, constant: 0).isActive = true
        amountErrorLabel.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 2).isActive = true
        amountErrorLabel.font = UIFont.systemFont(ofSize: 10)
        amountErrorLabel.textColor = UIColor.red
        addressErrorLabel.text = ""
        
        view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.leftAnchor.constraint(equalTo: amountTextField.leftAnchor, constant: 0).isActive = true
        sendButton.rightAnchor.constraint(equalTo: amountTextField.rightAnchor, constant: 0).isActive = true
        sendButton.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 30).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.backgroundColor = colorScheme.mainColor
        sendButton.setTitle("SEND JOBCOIN", for: .normal)
        sendButton.layer.cornerRadius = 10
        sendButton.addTarget(self, action: #selector(handleSendTapped), for: .touchUpInside)
        
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.rightAnchor.constraint(equalTo: sendButton.rightAnchor, constant: -20).isActive = true
        spinner.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
        
    }
    
    @objc func handleSendTapped() {
        
        if validateFields() {
            spinner.startAnimating()
            addressTextField.resignFirstResponder()
            amountTextField.resignFirstResponder()
            view.isUserInteractionEnabled = false
            let address = addressTextField.text!
            let amount = amountTextField.text!
            sendCoins(address: addressTextField.text!, amount: amountTextField.text!) { [weak self] (transactionCompleted, userUpdateCompleted) in
                guard let self = self else { return }
                if transactionCompleted {
                    self.spinner.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.addressTextField.text = ""
                    self.amountTextField.text = ""
                    self.confirmVC = SendConfirmationVC(amount: amount, address: address, colorScheme: self.colorScheme)
                    self.confirmVC!.definesPresentationContext = true
                    self.confirmVC!.modalPresentationStyle = .overFullScreen
                    self.confirmVC?.sendMoreHandler = { [weak self] in
                        self?.confirmVC?.dismiss(animated: true, completion: nil)
                    }
                    self.confirmVC?.finishedHandler = { [weak self] in
                        self?.confirmVC?.dismiss(animated: false, completion: { [weak self] in
                            self?.navigationController?.popViewController(animated: true)
                        })
                    }
                    self.present(self.confirmVC!, animated: false, completion: nil)
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.prepare()
                    generator.impactOccurred()
                    
                } else {
                    self.spinner.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                }
            }
        }

    }
    
    func sendCoins(address: String, amount: String, completion: ((_ transactionSuccess: Bool, _ userUpdatedSuccess: Bool) -> ())?) {
        
        apiClient.sendJobCoin(fromAddress: user.userAddress, toAddress: address, amount: amount, success: { [weak self] in
            guard let self = self else { return }
            self.apiClient.getInfoForAddress(address: self.user.userAddress, queue: DispatchQueue.main, success: { (response) in
                self.user.updateWithResponse(response: response)
                completion?(true, true)
            }, failure: { (error) in
                completion?(true, false)
            })
        }) { [weak self] (addressErrorMessage, amountErrorMessage) in
            guard let self = self else { return }
            if addressErrorMessage == nil && amountErrorMessage == nil {
                self.amountErrorLabel.text = "Unknown error.  Please try again"
            } else {
                self.addressErrorLabel.text = addressErrorMessage
                self.amountErrorLabel.text = amountErrorMessage
            }
            completion?(false, false)
        }
    }
    
    func validateFields() -> Bool {
        if let _ = addressTextField.text {
            if let amountString = amountTextField.text {
                if let _ = Float(amountString) {
                    return true
                } else {
                    amountErrorLabel.text = "Must be a real number"
                    return false
                }
            } else {
                amountErrorLabel.text = "Amount cannot be blank"
                return false
            }
        } else {
            addressErrorLabel.text = "Address cannot be blank"
            if let amountString = amountTextField.text {
                if let _ = Float(amountString) {
                    return false
                } else {
                    amountErrorLabel.text = "Must be a real number"
                    return false
                }
            } else {
                amountErrorLabel.text = "Amount cannot be blank"
                return false
            }
        }
    }
    
}

extension SendCoinVC : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            addressErrorLabel.text = nil
        } else if textField.tag == 1 {
            amountErrorLabel.text = nil
        }
        return true
    }
    
}


