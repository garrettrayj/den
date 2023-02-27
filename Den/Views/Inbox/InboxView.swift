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
        WithItems(
            scopeObject: profile,
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            readFilter: hideRead ? false : nil
        ) { _, items in
            GeometryReader { geometry in
                if profile.feedsArray.isEmpty {
                    NoFeedsView()
                } else if items.isEmpty {
                    AllReadSplashNoteView()
                } else {
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: Array(items)) { item in
                            FeedItemPreviewView(item: item)
                        }.modifier(MainBoardModifier())
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Inbox")
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    InboxBottomBarView(profile: profile, hideRead: $hideRead, visibleItems: items)
                }
            }
        }
    }
}
