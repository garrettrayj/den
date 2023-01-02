//
//  Trend+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/23/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

@objc(Trend)
public class Trend: NSManagedObject {
    var wrappedTitle: String {
        title ?? "Untitled"
    }

    var trendItemsArray: [TrendItem] {
        trendItems?.allObjects as? [TrendItem] ?? []
    }

    var items: [Item] {
        trendItemsArray
            .compactMap { $0.item }
            .sorted { $0.date > $1.date }
    }
    
    func visibleItems(_ hideRead: Bool) -> [Item] {
        items.filter { item in
            hideRead ? item.read == false : true
        }
    }

    var feeds: [Feed] {
        var feeds: Set<Feed> = []
        items.forEach { item in
            if let feed = item.feedData?.feed {
                feeds.insert(feed)
            }
        }

        return feeds.sorted { $0.wrappedTitle < $1.wrappedTitle }
    }

    static func create(in managedObjectContext: NSManagedObjectContext, profile: Profile) -> Trend {
        let trend = self.init(context: managedObjectContext)
        trend.id = UUID()
        trend.profileId = profile.id

        return trend
    }
}

extension Collection where Element == Trend {
    func firstMatchingID(_ uuidString: String) -> Trend? {
        self.first { trend in
            trend.id?.uuidString == uuidString
        }
    }
    
    func read() -> [Trend] {
        self.filter { trend in
            trend.items.unread().isEmpty == true
        }
    }

    func unread() -> [Trend] {
        self.filter { trend in
            trend.items.unread().isEmpty == false
        }
    }
}
