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
    let profile: Profile

    init(
        persistentContainer: NSPersistentContainer,
        profile: Profile
    ) {
        self.persistentContainer = persistentContainer
        self.profile = profile
        super.init()
    }

    override func main() {
        if isCancelled { return }

        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.automaticallyMergesChangesFromParent = false
        context.performAndWait {

            let allTags = findAllTags(context: context)
            print(allTags)

            do {
                try context.save()
            } catch {
                self.cancel()
            }
        }
    }

    private func processTags(tags: [NLTag]) -> [NLTag: Int] {
        var stats: [NLTag: Int] = [:]

        tags.forEach { tag in
            if let count = stats[tag] {
                stats[tag] = count + 1
            } else {
                stats[tag] = 0
            }
        }

        return stats
    }

    private func findAllTags(context: NSManagedObjectContext) -> [NLTag] {
        let profilePredicate = NSPredicate(
            format: "feedData.id IN %@",
            profile.feedDataIDs
        )

        let fetchRequest = FeedData.fetchRequest()
        fetchRequest.predicate = profilePredicate

        guard let feedDatas = try? context.fetch(fetchRequest) as [FeedData] else { return [] }

        var allTags: [NLTag] = []

        feedDatas.forEach { feedData in
            feedData.previewItems.forEach { item in
                allTags.append(contentsOf: getItemTags(item: item))
            }
        }

        return allTags.uniqued()
    }

    private func getItemTags(item: Item) -> [NLTag] {
        guard let text = item.title else { return [] }

        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]

        var tags: [NLTag] = []

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: options
        ) { tag, tokenRange in

            if let tag = tag {
                print("\(text[tokenRange]): \(tag.rawValue)")
                tags.append(tag)
            }

            return true
        }

        return tags
    }

}
