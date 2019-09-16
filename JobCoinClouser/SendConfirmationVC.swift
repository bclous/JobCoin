//
//  SendConfirmationVC.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/16/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit

class SendConfirmationVC: UIViewController {
    
    let amount : String
    let backgroundContainerView = UIView()
    let address : String
    let containerView = UIView()
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let finishedButton = UIButton()
    let sendMoreButton = UIButton()
    let colorScheme : ColorScheme
    
    var finishedHandler : (() -> ())?
    var sendMoreHandler : (() -> ())?
    
    init(amount: String, address: String, colorScheme: ColorScheme) {
        self.amount = amount
        self.address = address
        self.colorScheme = colorScheme
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init:coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        view.addSubview(backgroundContainerView)
        backgroundContainerView.translatesAutoresizingMaskIntoConstraints = false
        backgroundContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        backgroundContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        backgroundContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundContainerView.backgroundColor = UIColor.black
        backgroundContainerView.alpha = 0.8

        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        containerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 20
        containerView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        containerView.layer.borderWidth = 1
        
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowRadius = 4
        
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.text = "SUCCESS!"
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        containerView.addSubview(bodyLabel)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        bodyLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        bodyLabel.numberOfLines = 0
        bodyLabel.setContentHuggingPriority(.required, for: .vertical)
        bodyLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bodyLabel.text = "You have successfully sent \(amount) Jobcoins to \(address)."
        
        finishedButton.layer.cornerRadius = 10
        finishedButton.backgroundColor = colorScheme.mainColor
        finishedButton.setTitle("FINISHED", for: .normal)
        
        sendMoreButton.layer.cornerRadius = 10
        sendMoreButton.backgroundColor = colorScheme.mainColor
        sendMoreButton.setTitle("SEND MORE", for: .normal)
        
        finishedButton.addTarget(self, action: #selector(finishedTapped), for: .touchUpInside)
        sendMoreButton.addTarget(self, action: #selector(sendMoreTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [finishedButton, sendMoreButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        
        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 20).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20).isActive = true
    
    }
    
    @objc func finishedTapped() {
        finishedHandler?()
    }
    
    @objc func sendMoreTapped() {
        sendMoreHandler?()
    }

}
