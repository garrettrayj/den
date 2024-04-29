//
//  FeedWidget.swift
//  FeedWidget
//
//  Created by Garrett Johnson on 4/28/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import WidgetKit
import SwiftUI

struct FeedWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> FeedWidgetEntry {
        FeedWidgetEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> FeedWidgetEntry {
        FeedWidgetEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<FeedWidgetEntry> {
        var entries: [FeedWidgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = FeedWidgetEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct FeedWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct FeedWidgetEntryView: View {
    var entry: FeedWidgetProvider.Entry

    var body: some View {
        Text("Feed:")
        Text(entry.date, style: .time)

        Text("Foo:")
        Text(entry.configuration.favoriteEmoji)
    }
}

struct FeedWidget: Widget {
    let kind: String = "FeedWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: FeedWidgetProvider()
        ) { entry in
            FeedWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(
            Text("Feed Widget", comment: "Widget display name.")
        )
        .description(
            Text("Shows the latest items in a feed.", comment: "Widget description.")
        )
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    FeedWidget()
} timeline: {
    FeedWidgetEntry(date: .now, configuration: .smiley)
    FeedWidgetEntry(date: .now, configuration: .starEyes)
}
