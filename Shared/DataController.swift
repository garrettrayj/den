//
//  DataController.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog
import SwiftData

struct DataController {
    static let shared = DataController(inMemory: CommandLine.arguments.contains("-in-memory"))
    
    let container: ModelContainer
    
    let cloudModels: [any PersistentModel.Type] = [
        Blocklist.self,
        Bookmark.self,
        Feed.self,
        History.self,
        Page.self,
        Profile.self,
        Search.self,
        Tag.self
    ]
    
    let localModels: [any PersistentModel.Type] = [
        BlocklistStatus.self,
        FeedData.self,
        Item.self,
        Trend.self,
        TrendItem.self
    ]
    
    init(inMemory: Bool = false) {
        let cloudStoreURL: URL
        let localStoreURL: URL
        
        if inMemory {
            cloudStoreURL = URL(fileURLWithPath: "/dev/null/Den.sqlite")
            localStoreURL = URL(fileURLWithPath: "/dev/null/Den-Local.sqlite")
        } else {
            guard let appGroupURL = AppGroup.den.containerURL?.appending(
                path: "Library/Application Support",
                directoryHint: .isDirectory
            ) else {
                fatalError("Storage directory not available")
            }
            cloudStoreURL = appGroupURL.appending(path: "Den.sqlite")
            localStoreURL = appGroupURL.appending(path: "Den-Local.sqlite")
        }

        do {
            let cloudConfig = ModelConfiguration(
                "Den",
                schema: Schema(cloudModels),
                url: cloudStoreURL,
                allowsSave: true,
                cloudKitDatabase: .private("iCloud.net.devsci.den")
            )
            
            let localConfig = ModelConfiguration(
                "Den-Local",
                schema: Schema(localModels),
                url: localStoreURL,
                allowsSave: true,
                cloudKitDatabase: .none
            )
            
            container = try ModelContainer(
                for:
                    // Cloud models
                    Blocklist.self,
                    Bookmark.self,
                    Feed.self,
                    History.self,
                    Page.self,
                    Profile.self,
                    Search.self,
                    Tag.self,
                    // Local models
                    BlocklistStatus.self,
                    FeedData.self,
                    Item.self,
                    Trend.self,
                    TrendItem.self,
                configurations: cloudConfig, localConfig
            )
        } catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
}
