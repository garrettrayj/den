//
//  Date+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 12/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
