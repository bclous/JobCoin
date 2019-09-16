//
//  JobcoinChartView.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/16/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit
import SwiftChart

class JobcoinChartView: UIView {
    
    let chart = Chart()
    var data : [(x: Date, y: Double)] = []
    let spotlightView = ChartPointView()
    let dateClient = DateClient()
    let numberFormatter = NumberFormatter()
    var didEndTouchingHandler : (() ->())?

    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        chart.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        chart.topAnchor.constraint(equalTo: topAnchor).isActive = true
        chart.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        chart.gridColor = UIColor.clear
        chart.axesColor = UIColor.clear
        chart.backgroundColor = UIColor.white
        chart.minY = 0
        
        chart.lineWidth = 1
        chart.showYLabelsAndGrid = true
        chart.yLabelsOnRightSide = true
        chart.showXLabelsAndGrid = false
        
        chart.delegate = self
        
        addSubview(spotlightView)
        spotlightView.translatesAutoresizingMaskIntoConstraints = false
        spotlightView.isHidden = true
        
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
    }
    
    
    public func formatWithData(data: [(x: Date, y: Double)], color: UIColor) {
        self.data = data
        formatChart(color: color)
    }
    
    private func formatChart(color: UIColor) {
        chart.removeAllSeries()
        let chartData = seriesData(chartData: self.data)
        let series = ChartSeries(data: chartData)
        chart.add(series)
        series.color = color
        series.area = true
        
    }
    
    private func seriesData(chartData: [(x: Date, y: Double)]) -> [(x: Int, y: Double)] {
        var chartData : [(x: Int, y: Double)] = []
        for (index, dataPoint) in data.enumerated() {
            let x = index
            let y = dataPoint.y
            let value = (x,y)
            chartData.append(value)
        }
        return chartData
    }

}

extension JobcoinChartView : ChartDelegate {
    
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
        if let firstIndex = indexes.first, let first = firstIndex {
            print(first)
        }
        print(x)
        print(left)
        
        let index = Int(x.rounded())
        let value = chart.valueForSeries(0, atIndex: index)
        if let value = value {
            spotlightView.isHidden = false
            let date = data[index].x
            let min : CGFloat = 0
            let max : CGFloat = frame.width - 50
            var xPlacement = left - 15
            if xPlacement < min {
                xPlacement = min
            } else if xPlacement > max {
                xPlacement = max
            }
            
            spotlightView.frame.origin = CGPoint(x: xPlacement, y: 0)
            let dateString = dateClient.stringFromDate(date: date, format: "M/d/yy")
            let valueString = numberFormatter.string(for: value)
            spotlightView.format(dateLabel: dateString, valueLabel: valueString)
        }
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        print("finished touching")
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        didEndTouchingHandler?()
    }

}

class ChartPointView : UIView {
    
    let dateLabel = UILabel()
    let valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
    }
    
    private func customInit() {
        
        backgroundColor = UIColor.white
        addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 3).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -3).isActive = true
        
        dateLabel.font = UIFont.systemFont(ofSize: 8)
        
        addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 3).isActive = true
        valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
        valueLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -3).isActive = true
        
        valueLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3).isActive = true
        valueLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        dateLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        dateLabel.adjustsFontSizeToFitWidth = true
        valueLabel.adjustsFontSizeToFitWidth = true
        
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        dateLabel.font = UIFont.systemFont(ofSize: 8)
        valueLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        dateLabel.text = "-"
        valueLabel.text = "-"
    }
    
    func format(dateLabel: String?, valueLabel: String?) {
        self.dateLabel.text = dateLabel
        self.valueLabel.text = valueLabel
    }
    
}
