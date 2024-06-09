//
//  LatestItemsEntry.swift
//  Den
//
//  Created by Garrett Johnson on 5/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
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
    let sourceID: UUID?
    let sourceType: (any PersistentModel.Type)?
    let unread: Int
    let title: Text
    let favicon: Image?
    let symbol: String?
    let configuration: LatestItemsConfigurationIntent
    
    func url(item: WidgetItem? = nil) -> URL {
        var source = "inbox"
        if sourceType == Feed.self {
            source = "feed"
        } else if sourceType == Page.self {
            source = "page"
        }
        
        var url = URL(string: "den+widget://latest-items/\(source)")!
        
        if let sourceID = sourceID {
            url.append(path: "\(sourceID.uuidString)")
        }
        
        if let item = item {
            url.append(queryItems: [.init(name: "item", value: item.id.uuidString)])
        }
        
        return url
    }
}
