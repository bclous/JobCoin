//
//  TransactionCell.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/14/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    let leftBar = UIView()
    let transactionTypeLabel = UILabel()
    let timeStampLabel = UILabel()
    let transactionPartnerLabel = UILabel()
    let transactionAmountLabel = UILabel()
    let borderView = UIView()
    
    static let reuseIdentifier = "TransactionCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        
        contentView.backgroundColor = UIColor.white
        selectionStyle = .none
        
        contentView.addSubview(leftBar)
        leftBar.translatesAutoresizingMaskIntoConstraints = false
        leftBar.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        leftBar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        leftBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        leftBar.widthAnchor.constraint(equalToConstant: 5).isActive = true
        leftBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        contentView.addSubview(transactionTypeLabel)
        transactionTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionTypeLabel.leftAnchor.constraint(equalTo: leftBar.rightAnchor, constant: 10).isActive = true
        transactionTypeLabel.topAnchor.constraint(equalTo: leftBar.topAnchor).isActive = true
        
        transactionTypeLabel.adjustsFontSizeToFitWidth = true
        transactionTypeLabel.font = UIFont.systemFont(ofSize: 10)
        
        transactionTypeLabel.textColor = UIColor.gray
        
        contentView.addSubview(timeStampLabel)
        timeStampLabel.translatesAutoresizingMaskIntoConstraints = false
        timeStampLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        timeStampLabel.topAnchor.constraint(equalTo: leftBar.topAnchor, constant: 0).isActive = true
        
        timeStampLabel.leftAnchor.constraint(equalTo: transactionTypeLabel.rightAnchor, constant: 20).isActive = true
        
        timeStampLabel.textAlignment = .right
        timeStampLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeStampLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeStampLabel.font = UIFont.systemFont(ofSize: 10)
        timeStampLabel.textColor = UIColor.gray
        
        contentView.addSubview(transactionPartnerLabel)
        transactionPartnerLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionPartnerLabel.leftAnchor.constraint(equalTo: leftBar.rightAnchor, constant: 10).isActive = true
        transactionPartnerLabel.bottomAnchor.constraint(equalTo: leftBar.bottomAnchor).isActive = true
        transactionPartnerLabel.adjustsFontSizeToFitWidth = true
        transactionAmountLabel.font = UIFont.systemFont(ofSize: 18)
        
        contentView.addSubview(transactionAmountLabel)
        transactionAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        transactionAmountLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        transactionAmountLabel.bottomAnchor.constraint(equalTo: leftBar.bottomAnchor, constant: 0).isActive = true
        transactionAmountLabel.leftAnchor.constraint(equalTo: transactionPartnerLabel.rightAnchor, constant: 20).isActive = true
        transactionAmountLabel.textAlignment = .right
        transactionAmountLabel.setContentHuggingPriority(.required, for: .horizontal)
        transactionAmountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        transactionAmountLabel.font = UIFont.systemFont(ofSize: 18)
        
        contentView.addSubview(borderView)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        borderView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        borderView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        borderView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        borderView.backgroundColor = UIColor.groupTableViewBackground
        
        initializeElements()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        initializeElements()
    }
    
    func initializeElements() {
        leftBar.backgroundColor = UIColor.lightGray
        transactionPartnerLabel.text = "-"
        transactionTypeLabel.text = "-"
        timeStampLabel.text = "-"
        transactionAmountLabel.text = "-"
    }
    
    func formatCell(barColor: UIColor, topLeftTitle: String?, bottomLeftTitle: String?, topRightTitle: String, bottomRightTitle: String?) {
        leftBar.backgroundColor = barColor
        transactionTypeLabel.text = topLeftTitle
        transactionPartnerLabel.text = bottomLeftTitle
        timeStampLabel.text = topRightTitle
        transactionAmountLabel.text = bottomRightTitle
    }

}
