//
//  Trend+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/23/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData

@objc(Trend)
public class Trend: NSManagedObject {
    var wrappedTitle: String {
        title ?? "Untitled"
    }

    var trendItemsArray: [TrendItem] {
        guard
            let items = trendItems?.sortedArray(
                using: [NSSortDescriptor(key: "id", ascending: false)]
            ) as? [TrendItem]
        else { return [] }

        return items
    }

    var items: [Item] {
        trendItemsArray.compactMap { trendItem in
            return trendItem.item
        }
    }

    var feeds: [Feed] {
        var feeds: Set<Feed> = []
        items.forEach { item in
            if let feed = item.feedData?.feed {
                feeds.insert(feed)
            }
        }

        return feeds.sorted { lhs, rhs in
            lhs.wrappedTitle < rhs.wrappedTitle
        }
    }

    static func create(in managedObjectContext: NSManagedObjectContext, profile: Profile) -> Trend {
        let trend = self.init(context: managedObjectContext)
        trend.id = UUID()
        trend.profileId = profile.id

        return trend
    }
}
