//
//  BlocklistManager.swift
//  Den
//
//  Created by Garrett Johnson on 10/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import OSLog
import WebKit

@MainActor
final class BlocklistManager {
    static func getContentRuleLists() async -> [WKContentRuleList] {
        let modelContext = ModelContext(DataController.shared.container)
        
        guard let blocklists = try? modelContext.fetch(FetchDescriptor<Blocklist>()) as [Blocklist]
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
    
    static func removeContentRulesList(identifier: String?) async {
        guard let identifier = identifier else { return }

        try? await WKContentRuleListStore.default().removeContentRuleList(
            forIdentifier: identifier
        )
        Logger.main.info("Content rules list removed: \(identifier, privacy: .public)")
    }
    
    static func getCompiledRulesListIdentifiers() async -> [String] {
        return await WKContentRuleListStore.default().availableIdentifiers() ?? []
    }
    
    static func cleanupContentRulesLists() async {
        let modelContext = ModelContext(DataController.shared.container)
        
        guard let blocklists = try? modelContext.fetch(FetchDescriptor<Blocklist>()) as [Blocklist]
        else { return }
        
        let blocklistIdentifiers = blocklists.compactMap { $0.id?.uuidString }
        let ruleLists = await getCompiledRulesListIdentifiers()
        for ruleList in ruleLists where !blocklistIdentifiers.contains(ruleList) {
            await removeContentRulesList(identifier: ruleList)
        }
    }
    
    static func removeAllContentRulesLists() async {
        for ruleList in await getCompiledRulesListIdentifiers() {
            await removeContentRulesList(identifier: ruleList)
        }
    }
    
    static func initializeMissingContentRulesLists() async {
        let modelContext = ModelContext(DataController.shared.container)
        
        guard let blocklists = try? modelContext.fetch(FetchDescriptor<Blocklist>()) as [Blocklist]
        else { return }
        
        for blocklist in blocklists {
            guard let identifier = blocklist.id?.uuidString else { continue }
            let ruleLists = await getCompiledRulesListIdentifiers()
            if !ruleLists.contains(identifier) {
                Logger.main.info("""
                Blocklist “\(blocklist.wrappedName, privacy: .public)” is missing content rules, \
                refreshing now…
                """)
                await refreshContentRulesList(blocklist: blocklist)
            }
        }
        
        try? modelContext.save()
    }

    static func compileContentRulesList(identifier: String, json: String) async -> Bool {
        do {
            _ = try await WKContentRuleListStore.default().compileContentRuleList(
                forIdentifier: identifier,
                encodedContentRuleList: json
            )
            return true
        } catch {
            return false
        }
    }

    static func refreshContentRulesList(blocklist: Blocklist) async {
        let modelContext = ModelContext(DataController.shared.container)
        
        guard let blocklist = modelContext.model(for: blocklist.persistentModelID) as? Blocklist else {
            return
        }
        
        let blocklistStatus = blocklist.blocklistStatus ?? BlocklistStatus.create(
            in: modelContext,
            blocklist: blocklist
        )
        
        guard
            let identifier = blocklist.id?.uuidString,
            let url = blocklist.url,
            let (data, urlResponse) = try? await URLSession.shared.data(from: url),
            let httpResponse = urlResponse as? HTTPURLResponse
        else {
            blocklistStatus.compiledSuccessfully = false
            blocklistStatus.refreshed = .now
            blocklistStatus.httpCode = 0
            return
        }

        blocklistStatus.refreshed = .now
        blocklistStatus.httpCode = Int16(httpResponse.statusCode)
        blocklistStatus.compiledSuccessfully = await compileContentRulesList(
            identifier: identifier,
            json: String(decoding: data, as: UTF8.self)
        )

        Logger.main.info("Blocklist refreshed: \(blocklist.wrappedName, privacy: .public)")
    }
    
    static func refreshAllContentRulesLists() async {
        let modelContext = ModelContext(DataController.shared.container)
        
        guard let blocklists = try? modelContext.fetch(FetchDescriptor<Blocklist>()) as [Blocklist]
        else { return }
        
        for blocklist in blocklists {
            await refreshContentRulesList(blocklist: blocklist)
        }
    }
}
