//
//  TrendAnalysis.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

struct TrendAnalysis {
    static public func run(context: NSManagedObjectContext) {
        let workingTrends = self.analyzeTrends(context: context)
        
        let request: NSFetchRequest<Trend> = Trend.fetchRequest()
        guard let existingTrends = try? context.fetch(request) as [Trend] else { return }
        
        for workingTrend in workingTrends {
            var trend: Trend

            if let existingTrend = existingTrends.first(where: {$0.slug == workingTrend.slug}) {
                trend = existingTrend
            } else {
                trend = Trend.create(in: context)
                trend.title = workingTrend.title
                trend.slug = workingTrend.slug
                trend.tag = workingTrend.tag.rawValue
            }

            for item in workingTrend.items {
                _ = trend.trendItemsArray.first { trendItem in
                    trendItem.item == item
                } ?? TrendItem.create(in: context, trend: trend, item: item)
            }

            for trendItem in trend.trendItemsArray
            where !workingTrend.items.contains(where: { $0 == trendItem.item }) {
                context.delete(trendItem)
            }
        }

        // Delete trends not present in current analysis
        for trend in existingTrends where !workingTrends.contains(where: { $0.slug == trend.slug }) {
            context.delete(trend)
        }

        try? context.save()
    }

    static private func analyzeTrends(context: NSManagedObjectContext) -> [WorkingTrend] {
        var workingTrends: [WorkingTrend] = []

        let request = Item.fetchRequest()
        request.predicate = NSPredicate(format: "extra = %@", NSNumber(value: false))

        guard let items = try? context.fetch(request) else { return [] }

        for item in items {
            for (tokenText, tag) in item.wrappedTags {
                if let workingTrendIndex = workingTrends.firstIndex(where: { $0.slug == tokenText }) {
                    workingTrends[workingTrendIndex].items.append(item)
                } else {
                    workingTrends.append(
                        WorkingTrend(slug: tokenText, tag: tag, title: tokenText, items: [item])
                    )
                }
            }
        }

        return workingTrends.filter { workingTrend in
            workingTrend.items.count > 1 && workingTrend.feeds.count > 1
        }
    }
}
