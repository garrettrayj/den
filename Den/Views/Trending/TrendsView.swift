//
//  TrendsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct TrendsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @State var unreadCount: Int

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var body: some View {
        GeometryReader { geometry in
            if profile.trends.isEmpty {
                StatusBoxView(
                    message: Text("No Trends Available"),
                    caption: Text("Could not find any common organizations, people, or places in titles"),
                    symbol: "questionmark.folder"
                )
            } else {
                TrendsLayoutView(
                    profile: profile,
                    hideRead: $hideRead,
                    refreshing: $refreshing,
                    frameSize: geometry.size
                )
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onReceive(
            NotificationCenter.default
                .publisher(for: .itemStatus)
                .throttle(for: 1.0, scheduler: RunLoop.main, latest: true)
        ) { notification in
            guard
                let profileObjectID = notification.userInfo?["profileObjectID"] as? NSManagedObjectID,
                profileObjectID == profile.objectID
            else {
                return
            }
            unreadCount = profile.trends.unread().count
            profile.trends.forEach { $0.objectWillChange.send() }
        }
        .navigationTitle("Trends")
        .navigationDestination(for: TrendPanel.self) { detailPanel in
            switch detailPanel {
            case .trend(let trend):
                TrendView(
                    trend: trend,
                    unreadCount: trend.items.unread().count,
                    hideRead: $hideRead,
                    refreshing: $refreshing
                ).id(trend.id)
            }
        }
        .toolbar {
            ReadingToolbarContent(
                unreadCount: $unreadCount,
                hideRead: $hideRead,
                refreshing: $refreshing,
                centerLabel: Text("\(unreadCount) with unread")
            ) {
                SyncManager.toggleReadUnread(context: viewContext, items: profile.previewItems)
            }
        }
    }
}
