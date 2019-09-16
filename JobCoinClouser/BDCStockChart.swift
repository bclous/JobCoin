//
//  BDCStockChart.swift
//  Stock Genius Final
//
//  Created by Brian Clouser on 9/11/17.
//  Copyright © 2017 Clouser. All rights reserved.
//

import UIKit
import SwiftChart

private enum PriceChartType {
    case intraday
    case daily
    case weekly
    case monthly
    case quarterly
    case yearly
}

class BDCStockChart: UIView, ChartDelegate {
    
    let chart = Chart()
    public var data : [(x: Date, y: Float)] = []
    
    public var chartBackgroundColor = UIColor.black {
        didSet {
            chart.backgroundColor = chartBackgroundColor
        }
    }
    public var viewBackgroundColor = UIColor.black {
        didSet {
            backgroundColor = viewBackgroundColor
        }
    }
    
    public var axesColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1) {
        didSet {
            chart.axesColor = axesColor
        }
    }
    
    public var gridColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.3) {
        didSet {
            chart.gridColor = gridColor
        }
    }
    
    public var labelColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.3) {
        didSet {
            chart.labelColor = labelColor
        }
    }
    
    public var graphBodyAlpha = 0.3 {
        didSet {
            // change here
        }
    }
    
    public var positiveColor = UIColor.green
    public var negativeColor = UIColor.red
    
    public var xAxisDateFormat = "M/yy"

    private var sortedData : [(x: Date, y: Float)] = []
    private var chartData : [(x: Float, y: Float)] = []
    private var chartType : PriceChartType = .intraday
    private var isDaily : Bool = false
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private let numberFormatter = NumberFormatter()
    
    public var didTouchChartHandler : ((_ date: Date?, _ price: Float?) ->())?
    public var didEndTouchChartHandler : (() -> ())?
    
    var isIntraday = false

    override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.addSubview(chart)
        chart.delegate = self
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        chart.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        chart.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        chart.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        chart.xLabelsSkipLast = false
        chart.lineWidth = 1
        chart.hideHighlightLineOnTouchEnd = true
    }
    
    
    public func formatChartWithData(_ data: [(x: Date, y: Float)], isPositive: Bool) {
    
        if !data.isEmpty {
            self.data = data
            //TODO this is the problem on some intraday charts
            sortedData = data.sorted(by: {$0.x < $1.x})
            if let startDate = sortedData.first?.x, let endDate = sortedData.last?.x {
                if let days = Calendar.current.dateComponents([.day], from: startDate, to:endDate).day {
                    print(startDate)
                    print(endDate)
                    print("days: \(days)")
                    if days == 0 {
                        chartType = .intraday
                    } else if days <= 12 {
                        chartType = .daily
                    } else if days <= 60 {
                        chartType = .weekly
                    } else if days <= 200 {
                        chartType = .monthly
                    } else if days <= 500 {
                        chartType = .quarterly
                    } else {
                        chartType = .yearly
                    }
                } else {
                    chartType = .yearly
                }
            } else {
                chartType = .yearly
            }
            
            formatChart(isPositive: isPositive)
            xAxisDateFormat = xAxisFormatForChartType(chartType)
        }
    }
    
    private func xAxisFormatForChartType(_ chartType: PriceChartType) -> String {
        switch chartType {
        case .intraday:
            return xAxisLabels().count < 4 ? "h:mm a" : "h a"
        case .daily:
            return "E-d"
        case .weekly:
            return "M/d"
        case .monthly:
            return "MMM"
        case .quarterly:
            return "MMM"
        case .yearly:
            return "yyyy"
        }
    }
    
    private func formatChart(isPositive: Bool) {
    
        createChartData()
        let series = ChartSeries(data: chartData)
        series.color = isPositive ? UIColor.green : UIColor.red
        series.area = true
        chart.series.removeAll()
        chart.add(series)
        chart.xLabels = []
        chart.yLabels = []
        chart.xLabelsFormatter = { self.dateStringFromInt(Int($1))}
        chart.yLabelsOnRightSide = true
        chart.xLabelsSkipLast = true
        chart.minY = 0
    }
    
    private func dateStringFromInt(_ int: Int) -> String {
        
        let adjusted = sortedData.count - 1 == int ? int : int + 1
        let adjustedForDaily = chartType == .intraday ? int : adjusted
        let date = sortedData[adjustedForDaily].x
        return string(fromDate: date, withFormat: xAxisDateFormat)
    }
    
    private func createChartData() {
        
        chartData.removeAll()
        
        if !sortedData.isEmpty {
            for index in 0...sortedData.count - 1 {
                let stockDay = sortedData[index]
                let x = Float(index)
                let y = stockDay.y
                let value = (x,y)
                chartData.append(value)
            }
        }
    }
    
    private func firstInDayIndices() -> [Double] {
        
        var indices : [Int] = []
        
        for index in 0...sortedData.count - 1 {
            indices.append(index)
        }
        
        var indicesFloat : [Double] = []
        
        for index in indices {
            indicesFloat.append(Double(index))
        }
        
        return indicesFloat

    }
    
    private func firstInWeekIndices() -> [Double] {
        
        var indices : [Int] = []
        
        for index in 0...sortedData.count - 1 {
            let firstDay = sortedData[index]
            let firstWeekDay = calendar.component(.weekday, from: firstDay.x)
            let adjustedFirstWeekday = adjustedWeekday(component: firstWeekDay)
            
            if index == 0 {
                if adjustedFirstWeekday == 1 {
                    indices.append(index)
                }
            }
            
            if index < sortedData.count - 1 {
                
                let nextDay = sortedData[index + 1]
                let nextWeekDay = calendar.component(.weekday, from: nextDay.x)
                let adjustedNextWeekday = adjustedWeekday(component: nextWeekDay)
                
                if adjustedNextWeekday < adjustedFirstWeekday {
                    indices.append(index + 1)
                }
            }
        }
        
        var indicesFloat : [Double] = []
        
        for index in indices {
            indicesFloat.append(Double(index))
        }
        
        return indicesFloat
    }
    
    private func firstInMonthIndices() -> [Double] {
        
        var indices : [Int] = []
        
        for index in 0...sortedData.count - 1 {
            let firstDay = sortedData[index]
            let firstMonth = calendar.component(.month, from: firstDay.x)
            
            if index < sortedData.count - 1 {
                
                let nextDay = sortedData[index + 1]
                let nextMonth = calendar.component(.month, from: nextDay.x)
                
                if nextMonth != firstMonth {
                    indices.append(index + 1)
                }
            }
        }
        
        var indicesFloat : [Double] = []
        
        for index in indices {
            indicesFloat.append(Double(index))
        }
        
        return indicesFloat

    }
    
    private func firstInQuarterIndices() -> [Double] {
        
        var firstInQuarter : [Double] = []
        let firstInMonth = firstInMonthIndices()
        for index in 0...firstInMonth.count-1  {
            
            if index == 0 {
                firstInQuarter.append(firstInMonth[index])
            } else if (index) % 3 == 0 {
                firstInQuarter.append(firstInMonth[index])
            }
        }
        
        return firstInQuarter
    }
    
    private func firstInYearIndices() -> [Double] {
        var indices : [Int] = []
        
        for index in 0...sortedData.count - 1 {
            let firstDay = sortedData[index]
            let firstYear = calendar.component(.year, from: firstDay.x)
            
            if index < sortedData.count - 1 {
                
                let nextDay = sortedData[index + 1]
                let nextYear = calendar.component(.year, from: nextDay.x)
                
                if nextYear > firstYear {
                    indices.append(index + 1)
                }
            }
        }
        
        var indicesFloat : [Double] = []
        
        for index in indices {
            indicesFloat.append(Double(index))
        }
        
        return indicesFloat

    }
    
    private func intraDayIndices() -> [Double] {
        
        if sortedData.count < 45 {
            return firstIndex()
        } else if sortedData.count <= 75 {
            return firstInHourIndices(includeFirst: true)
        } else {
            return firstInHourIndices(includeFirst: false)
        }

    }
    
    private func firstIndex() -> [Double] {
        let firstIndex : Double = 1
        return [firstIndex]
    }
    
    private func firstInHourIndices(includeFirst: Bool) -> [Double] {
        
        var indices: [Double] = []
        
        if includeFirst {
            let firstIndex : Double = 1
            indices.append(firstIndex)
        }
        
        for index in 1...sortedData.count - 1 {
            
            let date = sortedData[index].x
            let minuteString = string(fromDate: date, withFormat: "mm")
            print(minuteString)
            if minuteString == "00" {
                indices.append(Double(index))
            }
        }
        
        return indices
        
    }
    
    
    
    private func adjustedWeekday(component: Int) -> Int {
        return component == 1 ? 7 : component - 1
    }
    
    private func xAxisLabels() -> [Double] {
        
        switch chartType {
        case .daily:
            return firstInDayIndices()
        case .weekly:
            return firstInWeekIndices()
        case .monthly:
            return firstInMonthIndices()
        case .quarterly:
            return firstInQuarterIndices()
        case .yearly:
            return firstInYearIndices()
        case .intraday:
            return intraDayIndices()
        }
    }
    
    
    private func yAxisLabels() -> [Double] {
        
        var minY : Float = sortedData[0].y
        var maxY : Float = 0
        
        for (_, closingPrice) in sortedData {
            maxY = closingPrice > maxY ? closingPrice : maxY
            minY = closingPrice < minY ? closingPrice : minY
        }
        
        var intMaxY = Int((maxY) + 1)
        var intMinY = Int(minY)
        var intMidY = 0
        var spread = intMaxY - intMinY
        
        if spread < 2 {
            return [Double(intMinY), Double(intMaxY)]
        } else {
            
            if spread % 2 == 0 {
                intMidY = spread / 2 + intMinY
            } else {
                if intMinY == 0 {
                    intMaxY += 1
                    spread = intMaxY - intMinY
                    intMidY = spread / 2 + intMinY
                } else {
                    intMinY -= 1
                    spread = intMaxY - intMinY
                    intMidY = spread / 2 + intMinY
                }
            }
            
            return [Double(intMinY), Double(intMidY),Double(intMaxY)]
        }
    }
    
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat) {
//        let index : Int = indexes.first as? Int ?? 0
//        let value = chart.valueForSeries(0, atIndex: index)
//        if let value = value {
//            priceDetailView.isHidden = false
//            let date = sortedData[index].x
//            let min : CGFloat = 0
//            let max : CGFloat = frame.width - 50
//            var xPlacement = left - 15
//            if xPlacement < min {
//                xPlacement = min
//            } else if xPlacement > max {
//                xPlacement = max
//            }
//
//            priceDetailView.configure(date: date, value: Float(value), isIntraday: chartType == .intraday)
//            priceDetailView.frame.origin = CGPoint(x: xPlacement, y: 0)
//
//            var overrideDate : Date? = nil
//            var overridePrice : Float? = nil
//            if chartType == .intraday {
//                overridePrice = Float(value)
//            } else {
//                overrideDate = date
//            }
//
//            didTouchChartHandler?(overrideDate, overridePrice)
//
//        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        didEndTouchChartHandler?()
//        priceDetailView.isHidden = true
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        didEndTouchChartHandler?()
//        priceDetailView.isHidden = true
    }
    
    
    private func string(fromDate date: Date?, withFormat format: String) -> String {
        if let date = date {
            dateFormatter.dateFormat = format
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
            let stringValue = dateFormatter.string(from: date)
            return stringValue
        } else {
            return ""
        }
    }
    
    private func date(fromString dateString: String, stringFormat: String) -> Date? {
        dateFormatter.dateFormat = stringFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")!
        return dateFormatter.date(from: dateString)
    }
    
    private func displayValue(float: Float?, decimalPlaces: Int, noDecimalsIfGreaterThanOrEqual: Float?, showDollarSign: Bool, showZero: Bool, showNegativeSign: Bool) -> String {
        
        var decimals = decimalPlaces
        if let max = noDecimalsIfGreaterThanOrEqual, let value = float {
            decimals = value.magnitude >= max ? 0 : 2
        }
        
        if let float = float {
            let finalValue = showNegativeSign ? float : abs(float)
            numberFormatter.numberStyle = showDollarSign ? .currency : .decimal
            numberFormatter.minimumFractionDigits = Int(decimals)
            numberFormatter.maximumFractionDigits = Int(decimals)
            let number = NSNumber(value: finalValue)
            let string = numberFormatter.string(from: number) ?? "-"
            return number.isEqual(to: NSNumber(value: 0)) && !showZero ? "-" : string
        } else {
            return "-"
        }
    }
    
}




