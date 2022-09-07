//
//  TrendView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct TrendView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @AppStorage("hideRead") var hideRead = false

    @ObservedObject var trend: Trend

    @State var unreadCount: Int
    @Binding var refreshing: Bool

    var body: some View {
        GeometryReader { geometry in
            if trend.items.isEmpty {
                StatusBoxView(
                    message: Text("Nothing Here"),
                    symbol: "tray"
                )
            } else if visibleItems.isEmpty {
                AllReadStatusView(hiddenItemCount: trend.items.read().count)
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: visibleItems) { item in
                        FeedItemPreviewView(item: item, refreshing: $refreshing)
                    }
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onReceive(
            NotificationCenter.default.publisher(for: .itemStatus, object: nil)
        ) { notification in
            guard
                let itemObjectID = notification.userInfo?["itemObjectID"] as? NSManagedObjectID,
                trend.items.map({ $0.objectID }).contains(itemObjectID),
                let read = notification.userInfo?["read"] as? Bool
            else {
                return
            }
            unreadCount += read ? -1 : 1
        }
        .navigationTitle(trend.wrappedTitle)
        .toolbar {
            ReadingToolbarContent(
                unreadCount: $unreadCount,
                hideRead: $hideRead,
                refreshing: .constant(false),
                centerLabel: Text("\(unreadCount) Unread")
            ) {
                SyncManager.toggleReadUnread(context: viewContext, items: trend.items)
                trend.objectWillChange.send()
            }
        }
    }

    private var visibleItems: [Item] {
        trend.items.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
