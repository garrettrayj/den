//
//  ContentFiltertUtility.swift
//  Den
//
//  Created by Garrett Johnson on 10/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import WebKit

import ContentBlockerConverter

final class ContentFiltertUtility {
    static func getRuleLists() async -> [WKContentRuleList] {
        let context = PersistenceController.shared.container.viewContext
        guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist] else {
            return []
        }

        var ruleLists: [WKContentRuleList] = []
        for blocklist in blocklists {
            guard let id = blocklist.id?.uuidString else { continue }
            if let ruleList = try? await WKContentRuleListStore
                .default()
                .contentRuleList(forIdentifier: id) 
            {
                ruleLists.append(ruleList)
            }
        }

        return ruleLists
    }

    static func refreshAllContentRulesLists(blocklists: [Blocklist]) async {
        for blocklist in blocklists {
            await refreshContentRulesList(blocklist: blocklist)
        }
    }

    static func refreshContentRulesList(blocklist: Blocklist) async {
        guard
            let url = blocklist.url,
            let (data, _) = try? await URLSession.shared.data(from: url)
        else {
            return
        }

        let blocklistString = String(decoding: data, as: UTF8.self)
        let blocklistArray = blocklistString.split(whereSeparator: \.isNewline).map { String($0) }
        let converter = ContentBlockerConverter()

        let result = converter.convertArray(rules: blocklistArray)

        _ = await MainActor.run {
            Task {
                _ = try? await WKContentRuleListStore.default().compileContentRuleList(
                    forIdentifier: blocklist.id?.uuidString ?? "NoID",
                    encodedContentRuleList: result.converted
                )
            }
        }

        let context = PersistenceController.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)

        await context.perform {
            guard let blocklistForUpdate = context.object(
                with: blocklist.objectID
            ) as? Blocklist else { return }

            let blocklistStatus = blocklistForUpdate.blocklistStatus ?? BlocklistStatus.create(
                in: context,
                blocklist: blocklistForUpdate
            )

            blocklistStatus.errorsCount = Int64(result.errorsCount)
            blocklistStatus.totalConvertedCount = Int64(result.totalConvertedCount)
            blocklistStatus.overLimit = result.overLimit
            blocklistStatus.refreshed = .now

            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
