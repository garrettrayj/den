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

    @State var unreadCount: Int

    @Binding var refreshing: Bool

    @AppStorage("hideRead") var hideRead = false

    var body: some View {
        GeometryReader { geometry in
            if profile.feedsArray.isEmpty {
                #if targetEnvironment(macCatalyst)
                StatusBoxView(
                    message: Text("Nothing Here"),
                    caption: Text("""
                    Add feeds by opening syndication links \
                    or click \(Image(systemName: "plus.circle")) to add by web address
                    """),
                    symbol: "tray"
                )
                #else
                StatusBoxView(
                    message: Text("Nothing Here"),
                    caption: Text("""
                    Add feeds by opening syndication links \
                    or tap \(Image(systemName: "plus.circle")) \
                    to add by web address
                    """),
                    symbol: "tray"
                )
                #endif
            } else if profile.previewItems.isEmpty {
                StatusBoxView(
                    message: Text("Nothing Here"),
                    symbol: "tray"
                )
            } else if profile.previewItems.unread().isEmpty && hideRead == true {
                AllReadView(hiddenItemCount: profile.previewItems.read().count)
            } else {
                AllItemsLayoutView(
                    profile: profile,
                    hideRead: $hideRead,
                    refreshing: $refreshing,
                    frameSize: geometry.size
                )
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    SubscriptionManager.showSubscribe()
                } label: {
                    Label("Add Feed", systemImage: "plus.circle")
                }.accessibilityIdentifier("add-feed-button")
            }

            ReadingToolbarContent(
                unreadCount: $unreadCount,
                hideRead: $hideRead,
                refreshing: $refreshing,
                centerLabel: Text("\(unreadCount) Unread")
            ) {
                withAnimation {
                    SyncManager.toggleReadUnread(context: viewContext, items: profile.previewItems)
                }
            }
        }
    }
}
