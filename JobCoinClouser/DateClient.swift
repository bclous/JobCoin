//
//  DateClient.swift
//  JobCoinClouser
//
//  Created by Brian Clouser on 9/15/19.
//  Copyright © 2019 Brian Clouser. All rights reserved.
//

import UIKit

class DateClient: NSObject {
    
    public let dateFormatter = DateFormatter()
    public let calendar = Calendar.current
    public let numberFormatter = NumberFormatter()
    
    func dateFromString(string: String, format: String) -> Date? {
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    func stringFromDate(date: Date?, format: String) -> String {
        if let date = date {
            dateFormatter.dateFormat = format
            return dateFormatter.string(from: date)
        } else {
            return ""
        }
    }
    
    func timeStampDisplay(fordate date: Date?) -> String {
        
        guard let date = date else { return "-" }
        
        let sameDay = datesAreSameDay(date1: Date(), date2: date)
        if sameDay {
            let seconds = Int(Date().timeIntervalSince(date))
            if seconds < 60 {
                return String(seconds) + "s"
            } else if seconds < 3600 {
                return String(seconds/60) + "m"
            } else {
                return stringFromDate(date: date, format: "h:mm a")
            }
        } else {
            return stringFromDate(date: date, format: "M/d/yyyy, h:mm a")
        }
        
    }
    
    func datesAreSameDay(date1: Date, date2: Date) -> Bool {
        
        let dateComponents = calendar.dateComponents(in: TimeZone.current, from: date1)
        let baseDateComponents = calendar.dateComponents(in: TimeZone.current, from: date2)
        
        let dateYear = dateComponents.year!
        let baseYear = baseDateComponents.year!
        let dateMonth = dateComponents.month!
        let baseMonth = baseDateComponents.month!
        let dateDay = dateComponents.day!
        let baseDay = baseDateComponents.day!
        
        return dateYear == baseYear && dateMonth == baseMonth && dateDay == baseDay
    }

}
