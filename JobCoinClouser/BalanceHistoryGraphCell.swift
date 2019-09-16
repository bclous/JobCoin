//
//  BalanceHistoryGraphCell.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/14/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit
import SwiftChart

class BalanceHistoryGraphCell: UITableViewCell {
    
    static let reuseIdentifier = "BalanceHistoryGraphCell"
    let chart = JobcoinChartView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        selectionStyle = .none
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        chart.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        chart.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        chart.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
    }

}
