//
//  AnalysisOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData

struct AnalysisOperation {
    unowned let container: NSPersistentContainer
    unowned let profileObjectID: NSManagedObjectID

    func execute() async {
        await container.performBackgroundTask { context in
            guard let profile = context.object(with: self.profileObjectID) as? Profile else { return }
            let workingTrends = self.analyzeTrends(profile: profile)

            for workingTrend in workingTrends {
                let trend = profile.trends.first { trend in
                    trend.slug == workingTrend.slug
                } ?? {
                    let trend = Trend.create(in: context, profile: profile)
                    trend.title = workingTrend.title
                    trend.slug = workingTrend.slug
                    trend.tag = workingTrend.tag.rawValue
                    return trend
                }()
                
                for item in workingTrend.items {
                    let _ = trend.trendItemsArray.first { trendItem in
                        trendItem.item == item
                    } ?? TrendItem.create(in: context, trend: trend, item: item)
                }
            }
            
            // Delete trends not present in current analysis
            for trend in profile.trends where !workingTrends.contains(where: { $0.slug == trend.slug }) {
                context.delete(trend)
            }
            
            try? context.save()
        }
    }

    private func analyzeTrends(profile: Profile) -> [WorkingTrend] {
        var workingTrends: Set<WorkingTrend> = []

        for item in profile.previewItems {
            for (tokenText, tag) in item.subjects() {
                let slug = tokenText.removingCharacters(in: .punctuationCharacters).lowercased()
                var (inserted, workingTrend) = workingTrends.insert(
                    WorkingTrend(slug: slug, tag: tag, title: tokenText, items: [item])
                )
                if !inserted {
                    workingTrend.items.append(item)
                    workingTrends.update(with: workingTrend)
                }
            }
        }

        return Array(workingTrends.filter { workingTrend in
            workingTrend.items.count > 1 && workingTrend.feeds.count > 1
        })
    }
}
