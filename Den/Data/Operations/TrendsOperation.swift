//
//  TrendsOperation.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import NaturalLanguage

/**
 Finds trending tags
 */
final class TrendsOperation: Operation {
    let persistentContainer: NSPersistentContainer
    let profileObjectID: NSManagedObjectID

    init(
        persistentContainer: NSPersistentContainer,
        profileObjectID: NSManagedObjectID
    ) {
        self.persistentContainer = persistentContainer
        self.profileObjectID = profileObjectID
        super.init()
    }

    override func main() {
        if isCancelled { return }

        let context = persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            guard let profile = context.object(with: self.profileObjectID) as? Profile else { return }

            // Clear existing
            profile.trends.forEach { trend in
                context.delete(trend)
            }

            let workingTrends = self.analyzeTrends(profile: profile, context: context)

            workingTrends.forEach { workingTrend in
                let trend = Trend.create(in: context, profile: profile)
                trend.title = workingTrend.text
                trend.slug = workingTrend.id

                workingTrend.items.forEach { item in
                    _ = TrendItem.create(in: context, trend: trend, item: item)
                }
            }

            do {
                try context.save()
            } catch {
                self.cancel()
            }
        }
    }

    private func analyzeTrends(profile: Profile, context: NSManagedObjectContext) -> [WorkingTrend] {
        var workingTrends: Set<WorkingTrend> = []

        profile.previewItems.forEach { item in
            item.subjects().forEach { subject in
                let id = subject.removingCharacters(in: .punctuationCharacters).lowercased()

                var (inserted, workingTrend) = workingTrends.insert(
                    WorkingTrend(id: id, text: subject, items: [item])
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
