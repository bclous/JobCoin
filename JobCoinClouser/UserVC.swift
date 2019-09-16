//
//  UserVC.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/13/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit

class UserVC: UIViewController {
    
    let user : User
    let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), style: .grouped)
    let sendButton = UIButton()
    var transactions : [Transaction]
    var chartData : [(x: Date, y: Double)]
    var orderDisplay : OrderType = .reverseChronological
    let refreshController = UIRefreshControl()
    
    let colorScheme : ColorScheme
    let apiClient : JobCoinAPIClient
    let dateClient = DateClient()
    
    init(user: User, colorScheme: ColorScheme, apiClient: JobCoinAPIClient) {
        self.user = user
        self.colorScheme = colorScheme
        self.apiClient = apiClient
        transactions = user.transactionsInOrder(orderType: orderDisplay)
        chartData = user.chartData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init:coder not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        configureNavBar()
        configureTableView()
        configureSendButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        self.tableView.reloadData()
    }
    
    func updateData() {
        transactions = user.transactionsInOrder(orderType: orderDisplay)
        chartData = user.chartData
    }
    
    private func configureNavBar() {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = colorScheme.mainColor
        navigationItem.hidesBackButton = true
        navigationController?.navigationItem.hidesBackButton = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        let image = UIImage(named: "icon")
        imageView.image = image
        logoContainer.addSubview(imageView)
        navigationItem.titleView = logoContainer
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutTapped))
    }
    
    private func configureSendButton() {
        view.addSubview(sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        sendButton.layer.cornerRadius = 23
        sendButton.backgroundColor = colorScheme.mainColor
        sendButton.setTitle("SEND JOBCOIN", for: .normal)
        sendButton.titleLabel?.textColor = UIColor.white
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    @objc func signOutTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func sendButtonTapped() {
        let sendVC = SendCoinVC(user: user, colorScheme: colorScheme, apiClient: apiClient)
        navigationController?.pushViewController(sendVC, animated: true)
    }
    
    @objc func refreshPulled() {
        apiClient.getInfoForAddress(address: user.userAddress, queue: DispatchQueue.main, success: { [weak self] (response) in
            guard let self = self else { return }
            self.user.updateWithResponse(response: response)
            self.updateData()
            self.tableView.reloadData()
            self.refreshController.endRefreshing()
        }) { (error) in
            self.refreshController.endRefreshing()
        }
    }
    
}

extension UserVC : UITableViewDelegate, UITableViewDataSource {
    
    private func configureTableView() {
        
        tableView.backgroundColor = UIColor.white
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        
        tableView.delegate = self
        tableView.dataSource = self
    
        tableView.register(AddressBalanceCell.classForCoder(), forCellReuseIdentifier: AddressBalanceCell.reuseIndentifier)
        tableView.register(BalanceHistoryGraphCell.classForCoder(), forCellReuseIdentifier: BalanceHistoryGraphCell.reuseIdentifier)
        tableView.register(TransactionCell.classForCoder(), forCellReuseIdentifier: TransactionCell.reuseIdentifier)
        tableView.register(SectionHeaderView.classForCoder(), forHeaderFooterViewReuseIdentifier: SectionHeaderView.reuseIndentifier)
        tableView.register(SectionFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: SectionFooterView.reuseIdentifier)
        tableView.separatorStyle = .none
        
        refreshController.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        tableView.refreshControl = refreshController
        
        tableView.estimatedRowHeight = 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let chartHeight : CGFloat = chartData.count > 1 ? 250 : 0
        return indexPath.section == 1 ? chartHeight : UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? transactions.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: AddressBalanceCell.reuseIndentifier) as! AddressBalanceCell
            cell.leftLabel.text = user.userAddress
            cell.rightLabel.text = user.balance
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: BalanceHistoryGraphCell.reuseIdentifier) as! BalanceHistoryGraphCell
            var color = UIColor.green
            if chartData.count > 1 {
                if let first = chartData.first, let last = chartData.last {
                    if last.y < first.y {
                        color = UIColor.red
                    }
                }
            }
            cell.chart.formatWithData(data: chartData, color: color)
            cell.chart.spotlightView.isHidden = true
            cell.chart.didEndTouchingHandler = { [weak self] in
                guard let self = self else { return }
                let chartIndexPath = IndexPath(row: 0, section: 1)
                self.tableView.reloadRows(at: [chartIndexPath], with: .none)
            }
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseIdentifier) as! TransactionCell
            let transaction = transactions[indexPath.row]
            let color = transaction.type == .sent ? UIColor.red : UIColor.green
            let partnerText : String = transaction.type == .sent ? transaction.toAddress : transaction.fromAddress ?? "(NEW)"
            let typeText = transaction.type == .sent ? "SENT TO" : "RECEIVED FROM"
            let timeStampText = dateClient.timeStampDisplay(fordate: transaction.date)
            let transactionAmountDisplay = transaction.type == .sent ? "(\(transaction.amount))" : transaction.amount
            cell.formatCell(barColor: color, topLeftTitle: typeText, bottomLeftTitle: partnerText, topRightTitle: timeStampText, bottomRightTitle: transactionAmountDisplay)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeaderView.reuseIndentifier) as! SectionHeaderView
        if section == 0 {
            headerView.leftLabel.text = "ADDRESS"
            headerView.rightLabel.text = "BALANCE"
        } else if section == 1 {
            return nil
        } else {
            headerView.leftLabel.text = "TRANSACTIONS"
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionFooterView.reuseIdentifier) as! SectionFooterView
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 1 ? CGFloat.leastNonzeroMagnitude : 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        } else if section == 1 {
            return CGFloat.leastNonzeroMagnitude
        } else {
            return 100
        }
    }
    
}

class SectionHeaderView : UITableViewHeaderFooterView {
    
    let leftLabel = UILabel()
    let rightLabel = UILabel()
    static let reuseIndentifier = "SectionHeaderView"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
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
        leftLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        leftLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        
        contentView.addSubview(rightLabel)
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        rightLabel.bottomAnchor.constraint(equalTo: leftLabel.bottomAnchor, constant: 0).isActive = true
        rightLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        rightLabel.leftAnchor.constraint(equalTo: leftLabel.rightAnchor, constant: 20).isActive = true
        rightLabel.setContentHuggingPriority(.required, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        rightLabel.textAlignment = .right
        
        leftLabel.font = UIFont.systemFont(ofSize: 10)
        rightLabel.font = UIFont.systemFont(ofSize: 10)
        leftLabel.textColor = UIColor.darkGray
        rightLabel.textColor = UIColor.darkGray
        
        leftLabel.text = ""
        rightLabel.text = ""
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftLabel.text = ""
        rightLabel.text = ""
    }
    
    
}

class SectionFooterView : UITableViewHeaderFooterView {
    
    static let reuseIdentifier = "SectionFooterView"
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        contentView.backgroundColor = UIColor.white
    }

}

