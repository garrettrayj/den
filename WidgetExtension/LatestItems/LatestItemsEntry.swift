//
//  LatestItemsEntry.swift
//  Den
//
//  Created by Garrett Johnson on 5/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI
import WidgetKit

struct LatestItemsEntry: TimelineEntry {
    struct WidgetItem: Identifiable {
        var id: UUID
        var itemTitle: String
        var feedTitle: String
        var favicon: Image?
        var thumbnail: Image?
    }
    
    let date: Date
    let items: [WidgetItem]
    let sourceType: NSManagedObject.Type?
    let unread: Int
    let title: Text
    let favicon: Image?
    let symbol: String?
    let configuration: LatestItemsConfigurationIntent
}
