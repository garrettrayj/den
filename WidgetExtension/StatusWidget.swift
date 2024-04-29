//
//  StatusWidget.swift
//  StatusWidget
//
//  Created by Garrett Johnson on 4/28/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import WidgetKit
import SwiftUI

struct StatusWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> StatusWidgetEntry {
        StatusWidgetEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> StatusWidgetEntry {
        StatusWidgetEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<StatusWidgetEntry> {
        var entries: [StatusWidgetEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = StatusWidgetEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct StatusWidgetEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct StatusWidgetEntryView: View {
    var entry: StatusWidgetProvider.Entry

    var body: some View {
        Text("Status:")
        Text(entry.date, style: .time)

        Text("HA:")
        Text(entry.configuration.favoriteEmoji)
    }
}

struct StatusWidget: Widget {
    let kind: String = "StatusWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: StatusWidgetProvider()
        ) { entry in
            StatusWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(
            Text("Status Widget", comment: "Widget display name.")
        )
        .description(
            Text("Shows last updated time and number of unread items.", comment: "Widget description.")
        )
        .supportedFamilies([.systemSmall])
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
    StatusWidget()
} timeline: {
    StatusWidgetEntry(date: .now, configuration: .smiley)
    StatusWidgetEntry(date: .now, configuration: .starEyes)
}
