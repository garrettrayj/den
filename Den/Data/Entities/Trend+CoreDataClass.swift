//
//  Trend+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/23/22.
//  Copyright © 2022 Garrett Johnson
//

import CoreData
import SwiftUI

@objc(Trend)
public class Trend: NSManagedObject {
    public var titleText: Text {
        if let title = title {
            return Text(title)
        } else {
            return Text("Untitled", comment: "Default trend title.")
        }
    }

    public var trendItemsArray: [TrendItem] {
        trendItems?.allObjects as? [TrendItem] ?? []
    }

    public var items: [Item] {
        trendItemsArray
            .compactMap { $0.item }
            .sorted { lhs, rhs in
                guard
                    let lhsPublished = lhs.published,
                    let rhsPublished = rhs.published
                else {
                    return false
                }

                return lhsPublished > rhsPublished
            }
    }

    public var hasUnread: Bool {
        items.unread().count > 0
    }

    public var profile: Profile? {
        (value(forKey: "profile") as? [Profile])?.first
    }

    public var feeds: [Feed] {
        Array(Set(items.compactMap { $0.feedData?.feed }))
            .sorted { $0.wrappedTitle < $1.wrappedTitle }
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
