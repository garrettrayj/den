//
//  Panels.swift
//  Den
//
//  Created by Garrett Johnson on 9/10/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

enum Panel: Hashable {
    case welcome
    case search
    case allItems
    case trends
    case page(Page)
    case settings
}

enum DetailPanel: Hashable {
    case trend(Trend)
    case feed(Feed?)
    case pageSettings(Page)
    case iconPicker(Page)
    case feedSettings(Feed)
    case item(Item)
    case profile(Profile)
    case importFeeds
    case exportFeeds
    case security
    case history
}