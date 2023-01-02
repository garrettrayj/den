//
//  DetailPanel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

enum DetailPanel: Hashable {
    case pageSettings(Page)
    case feed(Feed)
    case feedSettings(Feed)
    case item(Item)
    case trend(Trend)
}
