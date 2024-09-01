//
//  TrendItem+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/23/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData

@objc(TrendItem)
final public class TrendItem: NSManagedObject {
    static func create(
        in managedObjectContext: NSManagedObjectContext,
        trend: Trend,
        item: Item
    ) -> TrendItem {
        let trendItem = self.init(context: managedObjectContext)
        trendItem.id = UUID()
        trendItem.trend = trend
        trendItem.item = item

        return trendItem
    }
}
