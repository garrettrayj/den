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
@preconcurrency import WebKit

@MainActor
final class BlocklistManager {
    static func getContentRuleLists() async -> [WKContentRuleList] {
        var blocklistIDs: [String] = []
        let context = DataController.shared.container.newBackgroundContext()
        context.performAndWait {
            guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist]
            else { return }
            
            for blocklist in blocklists {
                guard let id = blocklist.id?.uuidString else { continue }
                blocklistIDs.append(id)
            }
        }
        
        var ruleLists: [WKContentRuleList] = []
        for blocklistID in blocklistIDs {
            var ruleList = try? await WKContentRuleListStore.default().contentRuleList(
                forIdentifier: blocklistID
            )
            if let ruleList {
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
        let context = DataController.shared.container.newBackgroundContext()
        
        context.performAndWait {
            guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist]
            else { return }
            
            let blocklistIdentifiers = blocklists.compactMap { $0.id?.uuidString }
            
            Task {
                let ruleLists = await getCompiledRulesListIdentifiers()
                for ruleList in ruleLists where !blocklistIdentifiers.contains(ruleList) {
                    await removeContentRulesList(identifier: ruleList)
                }
            }
        }
    }
    
    static func removeAllContentRulesLists() async {
        for ruleList in await getCompiledRulesListIdentifiers() {
            await removeContentRulesList(identifier: ruleList)
        }
    }
    
    static func initializeMissingContentRulesLists() async {
        let context = DataController.shared.container.newBackgroundContext()
        
        context.performAndWait {
            guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist]
            else { return }
            
            for blocklist in blocklists {
                guard let identifier = blocklist.id?.uuidString else { continue }
                let blocklistObjectID = blocklist.objectID
                
                Task {
                    let ruleLists = await getCompiledRulesListIdentifiers()
                    if !ruleLists.contains(identifier) {
                        Logger.main.info("""
                        Blocklistis missing content rules, refreshing now…
                        """)
                        await refreshContentRulesList(blocklistObjectID: blocklistObjectID)
                    }
                }
            }
            
            try? context.save()
        }
    }

    @MainActor
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

    static func refreshContentRulesList(
        blocklistObjectID: NSManagedObjectID
    ) async {
        var url: URL?
        var blocklistUUIDString: String?
        
        let context = DataController.shared.container.newBackgroundContext()
        context.performAndWait {
            guard let blocklist = context.object(with: blocklistObjectID) as? Blocklist else { return }
            
            url = blocklist.url
            blocklistUUIDString = blocklist.id?.uuidString
        }
        
        guard
            let url,
            let blocklistUUIDString,
            let (data, urlResponse) = try? await URLSession.shared.data(from: url),
            let httpResponse = urlResponse as? HTTPURLResponse
        else {
            return
        }
        
        let compiledSuccessfully = await compileContentRulesList(
            identifier: blocklistUUIDString,
            json: String(decoding: data, as: UTF8.self)
        )
        
        context.performAndWait {
            guard let blocklist = context.object(with: blocklistObjectID) as? Blocklist else { return }
            
            let blocklistStatus = blocklist.blocklistStatus ?? BlocklistStatus.create(
                in: context,
                blocklist: blocklist
            )

            blocklistStatus.refreshed = .now
            blocklistStatus.httpCode = Int16(httpResponse.statusCode)
            blocklistStatus.compiledSuccessfully = compiledSuccessfully
            
            try? context.save()
            
            Logger.main.info("Blocklist refreshed: \(blocklist.wrappedName, privacy: .public)")
        }
    }
    
    static func refreshAllContentRulesLists() async {
        let context = DataController.shared.container.newBackgroundContext()
        
        context.performAndWait {
            guard let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist]
            else { return }
            
            let blocklistObjectIDs = blocklists.map { $0.objectID }
            
            Task {
                for blocklistObjectID in blocklistObjectIDs {
                    await refreshContentRulesList(blocklistObjectID: blocklistObjectID)
                }
            }
        }
    }
}
