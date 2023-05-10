//
//  SearchLayout.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct SearchLayout: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    let query: String
    let items: [Item]

    var body: some View {
        if items.isEmpty {
            if hideRead {
                SplashNote(title: "No Unread Results")
            } else {
                SplashNote(title: "No Results")
            }
        } else {
            GeometryReader { geometry in
                ScrollView(.vertical) {
                    BoardView(geometry: geometry, list: items) { item in
                        if let feed = item.feedData?.feed {
                            if feed.wrappedPreviewStyle == .expanded {
                                FeedItemExpanded(item: item, feed: feed, profile: profile)
                            } else {
                                FeedItemCompressed(item: item, feed: feed, profile: profile)
                            }
                        }
                    }.modifier(MainBoardModifier())
                }
                .edgesIgnoringSafeArea(.horizontal)
            }
        }
    }
}
