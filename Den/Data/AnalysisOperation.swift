//
//  AnalysisOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

struct AnalysisOperation {
    unowned let container: NSPersistentContainer
    unowned let profileObjectID: NSManagedObjectID

    func execute() async {
        await container.performBackgroundTask { context in
            guard let profile = context.object(with: self.profileObjectID) as? Profile else { return }
            
            let workingTrends = self.analyzeTrends(profile: profile, context: context)

            for workingTrend in workingTrends {
                var trend: Trend

                if let existingTrend = profile.trends.first(where: {$0.slug == workingTrend.slug}) {
                    trend = existingTrend
                } else {
                    trend = Trend.create(in: context, profile: profile)
                    trend.title = workingTrend.title
                    trend.slug = workingTrend.slug
                    trend.tag = workingTrend.tag.rawValue
                }

                for item in workingTrend.items {
                    _ = trend.trendItemsArray.first { trendItem in
                        trendItem.item == item
                    } ?? TrendItem.create(in: context, trend: trend, item: item)
                }

                for trendItem in trend.trendItemsArray {
                    if !workingTrend.items.contains(where: { $0 == trendItem.item }) {
                        context.delete(trendItem)
                    }
                }
            }

            // Delete trends not present in current analysis
            for trend in profile.trends where !workingTrends.contains(where: { $0.slug == trend.slug }) {
                context.delete(trend)
            }

            try? context.save()
        }
    }

    private func analyzeTrends(profile: Profile, context: NSManagedObjectContext) -> [WorkingTrend] {
        var workingTrends: [WorkingTrend] = []

        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicates: [NSPredicate] = [
            NSPredicate(
                format: "feedData.id IN %@",
                profile.pagesArray.flatMap({ page in
                    page.feedsArray.compactMap { feed in
                        feed.feedData?.id
                    }
                })
            ),
            NSPredicate(format: "extra = %@", NSNumber(value: false))
        ]
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: predicates)

        guard let items = try? context.fetch(request) else { return [] }

        for item in items {
            for (tokenText, tag) in item.wrappedTags {
                let slug = tokenText.removingCharacters(in: .punctuationCharacters).lowercased()

                if let workingTrendIndex = workingTrends.firstIndex(where: { $0.slug == slug }) {
                    workingTrends[workingTrendIndex].items.append(item)
                } else {
                    workingTrends.append(WorkingTrend(slug: slug, tag: tag, title: tokenText, items: [item]))
                }
            }
        }

        return workingTrends.filter { workingTrend in
            workingTrend.items.count > 1 && workingTrend.feeds.count > 1
        }
    }
}
