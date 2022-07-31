//
//  TimelineView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    @AppStorage("hideRead") var hideRead = false

    var body: some View {
        GeometryReader { geometry in
            if profile.feedsArray.isEmpty {
                NoFeedsView()
            } else if profile.previewItems.isEmpty {
                NoItemsView()
            } else {
                ScrollView(.vertical) {
                    TimelineItemsView(profile: profile, hideRead: $hideRead, frameSize: geometry.size)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if targetEnvironment(macCatalyst)
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                subscriptionManager.showSubscribe()
            } label: {
                Label("Add Feed", systemImage: "plus.circle")
            }
            .accessibilityIdentifier("add-feed-button")
        }

        #else
        ToolbarItem {
            if refreshing {
                ProgressView()
                    .progressViewStyle(ToolbarProgressStyle())
            } else {
                Menu {
                    Button {
                        subscriptionManager.showSubscribe()
                    } label: {
                        Label("Add Feed", systemImage: "plus.circle")
                    }.accessibilityIdentifier("add-feed-button")
                } label: {
                    Label("Timeline Menu", systemImage: "ellipsis.circle").font(.body.weight(.medium))
                }
                .accessibilityIdentifier("timeline-menu")
            }
        }
        #endif

        ReadingToolbarContent(
            items: profile.previewItems,
            disabled: refreshing,
            hideRead: $hideRead
        ) {
            linkManager.toggleReadUnread(profile: profile)
        }
    }
}
