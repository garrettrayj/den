//
//  Date+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

extension Date {
    enum DayPeriods {
        case night
        case morning
        case afternoon
        case evening
    }

    func shortNoneDisplay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none

        return dateFormatter.string(from: self)
    }

    func shortShortDisplay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: self)
    }

    func mediumShortDisplay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: self)
    }

    func fullNoneDisplay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none

        return dateFormatter.string(from: self)
    }

    func fullShortDisplay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: self)
    }

    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }

    func dayPeriod() -> String {
        let hour = Calendar.current.component(.hour, from: self)
        switch hour {
        case 0...6:
            return "night"
        case 6...12:
            return "morning"
        case 12...18:
            return "afternoon"
        case 18...24:
            return "evening"
        default:
            return "anytime"
        }
    }

    func fullDayWithPeriod() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        let day = Calendar.current.component(.day, from: self)
        let dayOrdinal = numberFormatter.string(from: NSNumber(value: day)) ?? ""

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE '\(dayPeriod()),' MMMM '\(dayOrdinal)'"

        return dateFormatter.string(from: self)
    }
}
