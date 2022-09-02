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

    @State var unreadCount: Int = 0

    @Binding var refreshing: Bool

    @AppStorage("hideRead") var hideRead = false

    var body: some View {
        GeometryReader { geometry in
            if profile.trends.isEmpty {
                StatusBoxView(
                    message: Text("Nothing Here"),
                    caption: Text("Titles do not share any common subjects"),
                    symbol: "tray"
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
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ReadingToolbarContent(
                unreadCount: $unreadCount,
                hideRead: $hideRead,
                refreshing: $refreshing,
                centerLabel: Text("\(unreadCount) with Unread")
            ) {
                withAnimation {
                    SyncManager.toggleReadUnread(context: viewContext, items: profile.previewItems)
                }
            }
        }
    }
}
