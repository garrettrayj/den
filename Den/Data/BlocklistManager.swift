//
//  BlocklistManager.swift
//  Den
//
//  Created by Garrett Johnson on 10/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import WebKit

import ContentBlockerConverter

final class BlocklistManager {
    static func getContentRuleLists() async -> [WKContentRuleList] {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist]
        else { return [] }
        
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
        Logger.main.info("Content rules list removed: \(identifier, privacy: .public)")
    }
    
    @MainActor
    static func getCompiledRulesListIdentifiers() async -> [String] {
        return await WKContentRuleListStore.default().availableIdentifiers() ?? []
    }
    
    static func cleanupContentRulesLists() async {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist]
        else { return }
        
        let blocklistIdentifiers = blocklists.compactMap { $0.id?.uuidString }
        let ruleLists = await getCompiledRulesListIdentifiers()
        for ruleList in ruleLists where !blocklistIdentifiers.contains(ruleList) {
            await removeContentRulesList(identifier: ruleList)
        }
    }
    
    static func initializeMissingContentRulesLists() async {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist]
        else { return }
        
        for blocklist in blocklists {
            guard let identifier = blocklist.id?.uuidString else { continue }
            let ruleLists = await getCompiledRulesListIdentifiers()
            if !ruleLists.contains(identifier) {
                Logger.main.info("""
                Blocklist “\(blocklist.wrappedName, privacy: .public)” is missing content rules, \
                refreshing now…
                """)
                await refreshContentRulesList(blocklist: blocklist, context: context)
            }
        }
        
        try? context.save()
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

        DispatchQueue.main.async {
            blocklist.objectWillChange.send()
        }
        
        Logger.main.info("Blocklist refreshed: \(blocklist.wrappedName, privacy: .public)")
    }
    
    static func refreshAllContentRulesLists() async {
        let context = PersistenceController.shared.container.newBackgroundContext()
        
        guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist]
        else { return }
        
        for blocklist in blocklists {
            await refreshContentRulesList(blocklist: blocklist, context: context)
        }
        
        try? context.save()
    }
}
