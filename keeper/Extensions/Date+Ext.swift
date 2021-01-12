//
//  Date+Ext.swift
//  SivilKumbara
//
//  Created by Wookweb Creative Agency on 22.10.2020.
//

import Foundation

extension Date {
    
    func timeAgo() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "saniye"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "dakika"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "saat"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "gün"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "hafta"
        } else {
            quotient = secondsAgo / month
            unit = "ay"
        }
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "") önce"
    }
    
    func timeAgoForMessageList() -> String {
        
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "sn"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "dk"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "s"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "gün"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "hafta"
        } else {
            quotient = secondsAgo / month
            unit = "ay"
        }
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "") önce"
    }
}
