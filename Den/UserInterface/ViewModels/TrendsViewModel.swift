//
//  TrendsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI
import OSLog
import NaturalLanguage

class TrendsViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager
    let profile: Profile

    @Published var analyzing: Bool = true
    @Published var trends: [Trend] = []

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, profile: Profile) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profile = profile
    }

    func analyzeTrends() {
        self.trends = getTrends().filter { trend in
            trend.items.count > 1 && trend.feeds.count > 1
        }.sorted { a, b in
            a.items.count > b.items.count
        }

        self.analyzing = false
    }

    private func getTrends() -> Set<Trend> {
        let profilePredicate = NSPredicate(
            format: "feedData.id IN %@",
            profile.feedDataIDs
        )

        let fetchRequest = Item.fetchRequest()
        fetchRequest.predicate = profilePredicate

        guard let items = try? viewContext.fetch(fetchRequest) as [Item] else { return [] }

        var trends: Set<Trend> = []

        items.forEach { item in
            let subjects = getItemSubjects(item: item)
            subjects.forEach { (text, _) in
                var (inserted, trend) = trends.insert(
                    Trend(id: text.localizedLowercase, text: text, items: [item])
                )

                if !inserted {
                    trend.items.append(item)
                    trends.update(with: trend)
                }
            }
        }

        return trends
    }

    private func getItemSubjects(item: Item) -> [(String, String)] {
        guard let text = item.title else { return [] }

        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]

        var subjects: [(String, String)] = []

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: options
        ) { tag, tokenRange in
            // Get the most likely tag, and print it if it's a named entity.
            if let tag = tag, tags.contains(tag) {
                subjects.append((String(text[tokenRange]), tag.rawValue))
            }

            return true
        }

        return subjects
    }
}
