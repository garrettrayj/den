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

import SDWebImageSwiftUI

struct LatestItemsWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> LatestItemsWidgetEntry {
        LatestItemsWidgetEntry(
            date: Date(),
            items: [],
            configuration: LatestItemsConfigurationIntent()
        )
    }

    func snapshot(
        for configuration: LatestItemsConfigurationIntent,
        in context: Context
    ) async -> LatestItemsWidgetEntry {
        LatestItemsWidgetEntry(
            date: Date(),
            items: [],
            configuration: configuration
        )
    }
    
    func timeline(
        for configuration: LatestItemsConfigurationIntent,
        in context: Context
    ) async -> Timeline<LatestItemsWidgetEntry> {
        var entries: [LatestItemsWidgetEntry] = []
        
        let viewContext = PersistenceController.shared.container.viewContext
        
        let request = Item.fetchRequest()
        request.fetchLimit = 4
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.published, ascending: false)]
        
        print("HEYY")
        
        if let items = try? viewContext.fetch(request) {
            let entry = LatestItemsWidgetEntry(
                date: .now,
                items: items,
                configuration: configuration
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .never)
    }
}

struct LatestItemsWidgetEntry: TimelineEntry {
    let date: Date
    let items: [Item]
    let configuration: LatestItemsConfigurationIntent
}

struct LatestItemsWidgetEntryView: View {
    var entry: LatestItemsWidgetProvider.Entry

    var body: some View {
        VStack {
            HStack {
                Text("Latest Items").font(.title3)
                Spacer()
                Image("SimpleIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            
            ForEach(entry.items) { item in
                Divider()
                
                HStack {
                    item.titleText.font(.headline)
                    Spacer()
                }
            }
        }
    }
}

struct LatestItemsWidget: Widget {
    let kind: String = "LatestItemsWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LatestItemsConfigurationIntent.self,
            provider: LatestItemsWidgetProvider()
        ) { entry in
            LatestItemsWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(
            Text("Latest Items", comment: "Widget display name.")
        )
        .description(
            Text("Shows the latest items in a feed or page.", comment: "Widget description.")
        )
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
    }
}

extension LatestItemsConfigurationIntent {
    fileprivate static var inbox: LatestItemsConfigurationIntent {
        let intent = LatestItemsConfigurationIntent()
        
        return intent
    }
}

#Preview(as: .systemMedium) {
    LatestItemsWidget()
} timeline: {
    LatestItemsWidgetEntry(
        date: .now, 
        items: [],
        configuration: .inbox
    )
}
