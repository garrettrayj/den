//
//  AnalyzeTask.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

struct AnalyzeTask {
    static func execute() async {
        let context = DataController.shared.container.newBackgroundContext()

        context.performAndWait {
            guard let existingTrends = try? context.fetch(Trend.fetchRequest()) as [Trend] else {
                return
            }
            
            let workingTrends = analyzeTrends(context: context)
            
            for workingTrend in workingTrends {
                var trend: Trend

                if let existingTrend = existingTrends.first(where: { $0.slug == workingTrend.slug }) {
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
                
                trend.updateReadStatus()
            }

            // Delete trends not present in current analysis
            for trend in existingTrends where !workingTrends.contains(where: { $0.slug == trend.slug }) {
                context.delete(trend)
            }

            do {
                try context.save()
                Logger.main.info("Trend analysis complete")
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
    
    static private func analyzeTrends(context: NSManagedObjectContext) -> [WorkingTrend] {
        var workingTrends: [WorkingTrend] = []

        let request = Item.fetchRequest()
        request.predicate = NSPredicate(format: "extra = %@", NSNumber(value: false))

        guard let items = try? context.fetch(request) else { return [] }

        for item in items {
            for (tokenText, tag) in item.wrappedTags {
                if let workingTrendIndex = workingTrends.firstIndex(where: { $0.slug == tokenText }) {
                    workingTrends[workingTrendIndex].items.insert(item)
                    workingTrends[workingTrendIndex].feeds.insert(item.feedData!.feed!)
                } else {
                    workingTrends.append(
                        WorkingTrend(
                            slug: tokenText,
                            tag: tag,
                            title: tokenText,
                            items: [item],
                            feeds: [item.feedData!.feed!]
                        )
                    )
                }
            }
        }

        return workingTrends.filter { workingTrend in
            workingTrend.items.count > 1 && workingTrend.feeds.count > 1
        }
    }
}
