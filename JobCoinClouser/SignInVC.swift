//
//  ViewController.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/13/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    let apiClient : JobCoinAPIClient
    var addressEntry : String?
    
    let textField = UITextField()
    let signInButton = UIButton()
    let signInLabel = UILabel()
    let errorLabel = UILabel()
    let spinner = UIActivityIndicatorView()
    let colorScheme : ColorScheme
    
    let margin : CGFloat = 30
    
    init(apiClient: JobCoinAPIClient, colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
        self.apiClient = apiClient
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        textField.text = ""
    }
    
    func configureUI() {
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(signInLabel)
        signInLabel.translatesAutoresizingMaskIntoConstraints = false
        signInLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
        signInLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        signInLabel.text = "Sign In"
        signInLabel.font = UIFont.systemFont(ofSize: 20)
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: signInLabel.bottomAnchor, constant: 20).isActive = true
        textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: margin).isActive = true
        textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -margin).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.placeholder = "Enter your Jobcoin Address"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 5).isActive = true
        errorLabel.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: textField.rightAnchor).isActive = true
        errorLabel.textColor = UIColor.red
        errorLabel.font = UIFont.systemFont(ofSize: 10)
        errorLabel.adjustsFontSizeToFitWidth = true
        errorLabel.text = ""
        
        view.addSubview(signInButton)
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 30).isActive = true
        signInButton.leftAnchor.constraint(equalTo: textField.leftAnchor).isActive = true
        signInButton.rightAnchor.constraint(equalTo: textField.rightAnchor).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        signInButton.backgroundColor = colorScheme.mainColor
        signInButton.setTitle("SIGN IN", for: .normal)
        signInButton.layer.cornerRadius = 10
        
        signInButton.addTarget(self, action: #selector(handleSignIn), for: .touchUpInside)
        
        view.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.rightAnchor.constraint(equalTo: signInButton.rightAnchor, constant: -margin).isActive = true
        spinner.centerYAnchor.constraint(equalTo: signInButton.centerYAnchor).isActive = true
    }
    
    
    @objc func handleSignIn() {
        
        spinner.startAnimating()
        textField.resignFirstResponder()
        
        guard let entry = textField.text else { return }
        apiClient.getInfoForAddress(address: entry, queue: DispatchQueue.main, success: { [weak self] (response) in
            
            guard let self = self else { return }
            let user = User(address: entry)
            user.updateWithResponse(response: response)
            
            if user.balance == "0" && user.transactions.count == 0 {
                self.handleSignInFail(errorMessage: "Address does not exist. Case sensitive! Try again.")
            } else {
                let userVC = UserVC(user: user, colorScheme: self.colorScheme, apiClient: self.apiClient)
                self.spinner.stopAnimating()
                self.navigationController?.pushViewController(userVC, animated: true)
            }

        }) { [weak self] (error) in
            guard let self = self else { return }
            self.handleSignInFail(errorMessage: "Unable to connect.  Please try again!")
        }
        
    }
    
    func validateAddressInput() -> Bool {
        if let address = textField.text {
            if address == "" {
                errorLabel.text = "Address must be at least 1-character"
                return false
            } else {
                return true
            }
        } else {
            errorLabel.text = "Address must be at least 1-character"
            return false
        }
    }
    
    func handleSignInFail(errorMessage: String?) {
        self.errorLabel.text = errorMessage
        self.signInButton.isEnabled = false
        self.spinner.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }


}

extension SignInVC : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        signInButton.isEnabled = true
        errorLabel.text = ""
        return true
    }
    
}

