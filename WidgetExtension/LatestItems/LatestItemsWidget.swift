//
//  LatestItemsWidget.swift
//  LatestItemsWidget
//
//  Created by Garrett Johnson on 4/28/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import WidgetKit
import SwiftUI

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

struct LatestItemsWidget: Widget {
    let kind: String = "LatestItemsWidget"
    
    var persistentContainer = PersistenceController.shared.container
    
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
    }

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LatestItemsConfigurationIntent.self,
            provider: LatestItemsProvider(viewContext: persistentContainer.viewContext)
        ) { entry in
            LatestItemsView(entry: entry)
                .containerBackground(.background, for: .widget)
                .defaultAppStorage(.group)
        }
        .configurationDisplayName(
            Text("Latest Items", comment: "Widget display name.")
        )
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge
        ])
    }
}

extension LatestItemsConfigurationIntent {
    fileprivate static var inbox: LatestItemsConfigurationIntent {
        let intent = LatestItemsConfigurationIntent(
            source: SourceDetail(
                id: UUID(),
                entityType: nil,
                title: "Inbox",
                symbol: "tray",
                favicon: nil
            )
        )
        
        return intent
    }
}

#Preview(as: .systemMedium) {
    LatestItemsWidget()
} timeline: {
    LatestItemsEntry(
        date: .now, 
        items: [],
        sourceType: nil,
        unread: 10,
        title: Text("Inbox"),
        favicon: nil,
        symbol: nil,
        configuration: .inbox
    )
}
