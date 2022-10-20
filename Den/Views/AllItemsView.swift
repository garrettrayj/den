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
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var unreadCount: Int
    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var body: some View {
        GeometryReader { geometry in
            if profile.feedsArray.isEmpty {
                #if targetEnvironment(macCatalyst)
                StatusBoxView(
                    message: Text("No Feeds"),
                    caption: Text("""
                    Add feeds by opening syndication links \
                    or click \(Image(systemName: "plus.circle")) to add by web address
                    """),
                    symbol: "questionmark.folder"
                )
                #else
                StatusBoxView(
                    message: Text("No Feeds"),
                    caption: Text("""
                    Add feeds by opening syndication links \
                    or tap \(Image(systemName: "plus.circle")) \
                    to add by web address
                    """),
                    symbol: "questionmark.folder"
                )
                #endif
            } else if profile.previewItems.isEmpty {
                StatusBoxView(
                    message: Text("No Items"),
                    symbol: "questionmark.folder"
                )
            } else if profile.previewItems.unread().isEmpty && hideRead == true {
                AllReadStatusView(hiddenItemCount: profile.previewItems.read().count)
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: visibleItems) { item in
                        FeedItemPreviewView(item: item, refreshing: $refreshing)
                    }
                    .modifier(TopLevelBoardPaddingModifier())
                    .clipped()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("All Items")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if refreshing {
                    ProgressView().progressViewStyle(ToolbarProgressStyle())
                } else {
                    Button {
                        SubscriptionManager.showSubscribe()
                    } label: {
                        Label("Add Feed", systemImage: "plus.circle")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .accessibilityIdentifier("add-feed-button")
                }
            }

            ReadingToolbarContent(
                unreadCount: $unreadCount,
                hideRead: $hideRead,
                refreshing: $refreshing,
                centerLabel: Text("\(unreadCount) Unread")
            ) {
                SyncManager.toggleReadUnread(context: viewContext, items: profile.previewItems)
            }
        }
    }

    private var visibleItems: [Item] {
        profile.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
