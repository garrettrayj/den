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

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LatestItemsConfigurationIntent.self,
            provider: LatestItemsProvider()
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

#Preview(as: .systemMedium) {
    LatestItemsWidget()
} timeline: {
    LatestItemsEntry(
        date: .now, 
        items: [],
        sourceID: nil,
        sourceType: nil,
        unread: 10,
        title: Text("Inbox", comment: "Widget title."),
        favicon: nil,
        symbol: nil,
        configuration: .init(source: SourceQuery.defaultSource)
    )
}
