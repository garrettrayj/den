//
//  AnalysisOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData

final class AnalysisOperation {
    unowned let container: NSPersistentContainer
    unowned let profileObjectID: NSManagedObjectID

    init(
        container: NSPersistentContainer,
        profileObjectID: NSManagedObjectID
    ) {
        self.container = container
        self.profileObjectID = profileObjectID
    }

    func execute() async {
        await container.performBackgroundTask { context in
            guard let profile = context.object(with: self.profileObjectID) as? Profile else { return }

            // Clear existing
            profile.trends.forEach { trend in
                context.delete(trend)
            }

            let workingTrends = self.analyzeTrends(profile: profile, context: context)

            workingTrends.forEach { workingTrend in
                let trend = Trend.create(in: context, profile: profile)
                trend.title = workingTrend.title
                trend.slug = workingTrend.slug
                trend.tag = workingTrend.tag.rawValue

                workingTrend.items.forEach { item in
                    _ = TrendItem.create(in: context, trend: trend, item: item)
                }
            }
            
            try? context.save()
        }
    }

    private func analyzeTrends(profile: Profile, context: NSManagedObjectContext) -> [WorkingTrend] {
        var workingTrends: Set<WorkingTrend> = []

        profile.previewItems.forEach { item in
            item.subjects().forEach { (tokenText, tag) in
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
