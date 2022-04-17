//
//  Date+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

extension Date {
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

    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
