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
                    BoardView(width: geometry.size.width, list: profile.visibleItems(hideRead)) { item in
                        FeedItemPreviewView(item: item)
                    }
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
