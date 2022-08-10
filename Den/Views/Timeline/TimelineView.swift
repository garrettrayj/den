//
//  TimelineView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TimelineView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var syncManager: SyncManager

    @ObservedObject var profile: Profile

    @State var unreadCount: Int

    @Binding var refreshing: Bool

    @AppStorage("hideRead") var hideRead = false

    var body: some View {
        GeometryReader { geometry in
            if profile.feedsArray.isEmpty {
                NoFeedsView()
            } else if profile.previewItems.isEmpty {
                NoItemsView()
            } else if profile.previewItems.unread().isEmpty && hideRead == true {
                AllReadView(hiddenItemCount: profile.previewItems.read().count)
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: visibleItems) { item in
                        FeedItemPreviewView(item: item)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .padding(.top, 8)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onReceive(
            NotificationCenter.default.publisher(for: .profileItemStatus, object: profile.objectID)
        ) { notification in
            guard let read = notification.userInfo?["read"] as? Bool else { return }
            unreadCount += read ? -1 : 1
        }
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
            unreadCount: $unreadCount,
            hideRead: $hideRead
        ) {
            syncManager.toggleReadUnread(items: profile.previewItems)
        }
    }

    private var visibleItems: [Item] {
        profile.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
