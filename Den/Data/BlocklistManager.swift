//
//  BlocklistManager.swift
//  Den
//
//  Created by Garrett Johnson on 10/6/23.
//  Copyright © 2023 Garrett Johnson
//

import CoreData
import OSLog
import WebKit

import ContentBlockerConverter

final class BlocklistManager {
    static func getContentRuleLists(blocklists: [Blocklist]) async -> [WKContentRuleList] {
        var ruleLists: [WKContentRuleList] = []
        for blocklist in blocklists {
            guard let id = blocklist.id?.uuidString else { continue }
            if let ruleList = try? await WKContentRuleListStore.default().contentRuleList(
                forIdentifier: id
            ) {
                ruleLists.append(ruleList)
            }
        }

        return ruleLists
    }
    
    @MainActor
    static func removeContentRulesList(identifier: String?) async {
        guard let identifier = identifier else { return }

        try? await WKContentRuleListStore.default().removeContentRuleList(
            forIdentifier: identifier
        )
        Logger.main.info("Removed content rules list '\(identifier)'")
    }
    
    @MainActor
    static func getCompiledRulesListIdentifiers() async -> [String] {
        return await WKContentRuleListStore.default().availableIdentifiers() ?? []
    }
    
    static func cleanupContentRulesLists(blocklists: [Blocklist]) async {
        let ruleLists = await getCompiledRulesListIdentifiers()
        let blocklistIdentifiers = blocklists.compactMap { $0.id?.uuidString }
        for ruleList in ruleLists where !blocklistIdentifiers.contains(ruleList) {
            await removeContentRulesList(identifier: ruleList)
        }
    }
    
    static func initializeMissingContentRulesLists(
        blocklists: [Blocklist],
        context: NSManagedObjectContext
    ) async {
        let ruleLists = await getCompiledRulesListIdentifiers()
        for blocklist in blocklists {
            guard let identifier = blocklist.id?.uuidString else { continue }
            if !ruleLists.contains(identifier) {
                await refreshContentRulesList(blocklist: blocklist, context: context)
                Logger.main.info("Initialized blocklist missing rules '\(blocklist.wrappedName)'")
            }
        }
    }

    @MainActor
    static func compileContentRulesList(identifier: String, json: String) async {
        _ = try? await WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: identifier,
            encodedContentRuleList: json
        )
    }

    static func refreshContentRulesList(
        blocklist: Blocklist,
        context: NSManagedObjectContext
    ) async {
        guard
            let identifier = blocklist.id?.uuidString,
            let url = blocklist.url,
            let (data, _) = try? await URLSession.shared.data(from: url)
        else {
            return
        }

        let blocklistString = String(decoding: data, as: UTF8.self)
        let blocklistArray = blocklistString.split(whereSeparator: \.isNewline).map { String($0) }
        let converter = ContentBlockerConverter()

        let result = converter.convertArray(rules: blocklistArray)

        await compileContentRulesList(identifier: identifier, json: result.converted)

        let blocklistStatus = blocklist.blocklistStatus ?? BlocklistStatus.create(
            in: context,
            blocklist: blocklist
        )

        blocklistStatus.errorsCount = Int64(result.errorsCount)
        blocklistStatus.totalConvertedCount = Int64(result.totalConvertedCount)
        blocklistStatus.overLimit = result.overLimit
        blocklistStatus.refreshed = .now

        blocklist.objectWillChange.send()
    }
    
    static func refreshAllContentRulesLists(
        blocklists: [Blocklist],
        context: NSManagedObjectContext
    ) async {
        for blocklist in blocklists {
            await refreshContentRulesList(blocklist: blocklist, context: context)
        }
    }
}
