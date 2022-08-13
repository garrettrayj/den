//
//  AllItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct AllItemsView: View {
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var syncManager: SyncManager

    @ObservedObject var profile: Profile

    @State var unreadCount: Int
    @State private var phony: Bool = false // For triggering redraw

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
        .onChange(of: hideRead, perform: { _ in
            phony.toggle()
        })
        .onReceive(NotificationCenter.default.publisher(for: .itemStatus)) { notification in
            guard
                let profileObjectID = notification.userInfo?["profileObjectID"] as? NSManagedObjectID,
                profileObjectID == profile.objectID,
                let read = notification.userInfo?["read"] as? Bool
            else {
                return
            }
            unreadCount += read ? -1 : 1
        }
        .navigationTitle("All Items")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ReadingToolbarContent(unreadCount: $unreadCount, hideRead: $hideRead, refreshing: $refreshing) {
            syncManager.toggleReadUnread(items: profile.previewItems)
        }
    }

    private var visibleItems: [Item] {
        profile.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
