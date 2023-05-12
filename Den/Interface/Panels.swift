//
//  Panels.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

enum DetailPanel: Hashable {
    case welcome
    case search
    case inbox
    case trending
    case page(Page)
    case settings
}

enum SubDetailPanel: Hashable {
    case feed(Feed)
    case item(Item)
    case trend(Trend)
    case feedSettings(Feed)
    case pageSettings(Page)
    case profileSettings(Profile)
    case importFeeds(Profile)
    case exportFeeds(Profile)
    case security(Profile)
}
