//
//  LatestItemsEntry.swift
//  Den
//
//  Created by Garrett Johnson on 5/5/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI
import WidgetKit

struct LatestItemsEntry: TimelineEntry {
    struct WidgetItem: Identifiable {
        var id: UUID
        var itemTitle: String
        var feedTitle: String
        var faviconURL: URL?
        var faviconImage: Image?
        var thumbnailURL: URL?
        var thumbnailImage: Image?
    }
    
    var date: Date
    var items: [WidgetItem]
    var sourceID: UUID?
    var sourceType: NSManagedObject.Type?
    var unread: Int
    var title: Text
    var faviconURL: URL?
    var faviconImage: Image?
    var symbol: String?
    var configuration: LatestItemsConfigurationIntent
    
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
