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
import SwiftUI

@objc(Trend)
public class Trend: NSManagedObject {
    var titleText: Text {
        if let title = title {
            return Text(title)
        } else {
            return Text("Untitled", comment: "Default trend title.")
        }
    }

    var trendItemsArray: [TrendItem] {
        trendItems?.allObjects as? [TrendItem] ?? []
    }

    var items: [Item] {
        trendItemsArray
            .compactMap { $0.item }
            .sorted { $0.date > $1.date }
    }

    var hasUnread: Bool {
        items.unread().count > 0
    }

    func visibleItems(_ hideRead: Bool) -> [Item] {
        items.filter { item in
            hideRead ? item.read == false : true
        }
    }

    public var profile: Profile? {
        let values = value(forKey: "profile") as? [Profile]
        if let unwrappedValues = values {
            return unwrappedValues.first
        }

        return nil
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
    func containingUnread() -> [Trend] {
        self.filter { $0.hasUnread }
    }
}
