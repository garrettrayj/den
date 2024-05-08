//
//  AutoRefreshInterval.swift
//  Den
//
//  Created by Garrett Johnson on 5/7/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

enum AutoRefreshInterval: Int, CaseIterable {
    #if DEBUG
    case fiveMinutes = 300
    #endif
    case zero = 0
    case halfHour = 1800
    case oneHour = 3600
    case twoHours = 7200
    case threeHours = 10800
    case sixHours = 21600
    case twelveHours = 43200
    case twentyFourHours = 86400
}
