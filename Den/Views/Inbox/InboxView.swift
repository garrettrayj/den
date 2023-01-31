//
//  InboxView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct InboxView: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var body: some View {
        GeometryReader { geometry in
            if profile.feedsArray.isEmpty {
                #if targetEnvironment(macCatalyst)
                SplashNoteView(
                    title: Text("No Feeds"),
                    caption: Text("""
                    Tap \(Image(systemName: "plus.circle")), \
                    open syndication links, or drag and drop URLs to add feeds.
                    """)
                )
                #else
                SplashNoteView(
                    title: Text("No Feeds"),
                    caption: Text("""
                    Add feeds by opening syndication links \
                    or tap \(Image(systemName: "plus.circle")) \
                    to add by web address
                    """)
                )
                #endif
            } else if profile.previewItems.isEmpty {
                SplashNoteView(
                    title: Text("No Items"),
                    caption: Text("Refresh \(Image(systemName: "arrow.clockwise")) to fetch content.")
                )
            } else if profile.previewItems.unread().isEmpty && hideRead == true {
                AllReadSplashNoteView(hiddenItemCount: profile.previewItems.read().count)
            } else {
                ScrollView(.vertical) {
                    BoardView(width: geometry.size.width, list: profile.visibleItems(hideRead)) { item in
                        FeedItemPreviewView(item: item)
                    }
                    Spacer()
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Inbox")
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                InboxBottomBarView(
                    profile: profile,
                    hideRead: $hideRead
                )
            }
        }
    }
}
