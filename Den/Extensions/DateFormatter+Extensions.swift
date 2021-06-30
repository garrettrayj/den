//
//  DateFormatter+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

extension DateFormatter {
    static func create(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.locale = .autoupdatingCurrent
        
        return dateFormatter
    }
    
    static func getFormattedDate(date: Date, format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        
        return dateformat.string(from: date)
    }
}
