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
final public class Trend: NSManagedObject {
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
            .sorted(using: SortDescriptor(\.published, order: .reverse))
    }

    var profile: Profile? {
        (value(forKey: "profile") as? [Profile])?.first
    }

    var feeds: [Feed] {
        Set(items.compactMap { $0.feedData?.feed }).sorted { $0.wrappedTitle < $1.wrappedTitle }
    }
    
    func updateReadStatus() {
        read = items.unread.isEmpty
    }

    static func create(in managedObjectContext: NSManagedObjectContext) -> Trend {
        let trend = self.init(context: managedObjectContext)
        trend.id = UUID()

        return trend
    }
}

extension Collection where Element == Trend {
    var containingUnread: [Trend] {
        self.filter { !$0.read }
    }
}
