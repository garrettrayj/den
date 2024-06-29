//
//  AnalyzeTask.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import SwiftData

struct AnalyzeTask {
    func execute() async {
        let modelContext = ModelContext(DataController.shared.container)
        
        guard let existingTrends = try? modelContext.fetch(FetchDescriptor<Trend>()) as [Trend] else {
            return
        }
        
        let workingTrends = self.analyzeTrends(modelContext: modelContext)
        for workingTrend in workingTrends {
            var trend: Trend

            if let existingTrend = existingTrends.first(where: {$0.slug == workingTrend.slug}) {
                trend = existingTrend
            } else {
                trend = Trend.create(in: modelContext)
                trend.title = workingTrend.title
                trend.slug = workingTrend.slug
                trend.tag = workingTrend.tag.rawValue
            }

            for item in workingTrend.items {
                if let trendItems = trend.items, !trendItems.contains(item) {
                    trend.items?.append(item)
                }
            }

            for trendItem in trend.items ?? []
            where !workingTrend.items.contains(where: { $0 == trendItem }) {
                trend.items?.removeAll(where: { $0 == trendItem })
            }
            
            trend.updateReadStatus()
        }

        // Delete trends not present in current analysis
        for trend in existingTrends where !workingTrends.contains(where: { $0.slug == trend.slug }) {
            modelContext.delete(trend)
        }
        
        try? modelContext.save()
    }
    
    private func analyzeTrends(modelContext: ModelContext) -> [WorkingTrend] {
        var workingTrends: [WorkingTrend] = []

        var request = FetchDescriptor<Item>()
        request.predicate = #Predicate<Item> { $0.extra == false }

        guard let items = try? modelContext.fetch(request) else { return [] }

        for item in items {
            for (tokenText, tag) in item.wrappedTags {
                if let workingTrendIndex = workingTrends.firstIndex(where: { $0.slug == tokenText }) {
                    workingTrends[workingTrendIndex].items.insert(item)
                    workingTrends[workingTrendIndex].feeds.insert(item.feedData!.feed!)
                } else {
                    if let feed = item.feedData?.feed {
                        workingTrends.append(
                            WorkingTrend(
                                slug: tokenText,
                                tag: tag,
                                title: tokenText,
                                items: [item],
                                feeds: [feed]
                            )
                        )
                    }
                }
            }
        }

        return workingTrends.filter { workingTrend in
            workingTrend.items.count > 1 && workingTrend.feeds.count > 1
        }
    }
}
