//
//  AddressBalanceCell.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/14/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit

class AddressBalanceCell: UITableViewCell {
    
    let leftLabel = UILabel()
    let rightLabel = UILabel()
    static let reuseIndentifier = "AddressBalanceCell"
    
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
        
        contentView.addSubview(leftLabel)
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        leftLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        leftLabel.adjustsFontSizeToFitWidth = true
        
        contentView.addSubview(rightLabel)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.bottomAnchor.constraint(equalTo: leftLabel.bottomAnchor, constant: 0).isActive = true
        rightLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        rightLabel.leftAnchor.constraint(equalTo: leftLabel.rightAnchor, constant: 20).isActive = true
        rightLabel.setContentHuggingPriority(.required, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightLabel.textAlignment = .right
        
        leftLabel.font = UIFont.systemFont(ofSize: 20)
        rightLabel.font = UIFont.systemFont(ofSize: 20)
        
        leftLabel.setContentHuggingPriority(.required, for: .vertical)
        rightLabel.setContentHuggingPriority(.required, for: .vertical)
        leftLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        
        selectionStyle = .none
        
    }

}
