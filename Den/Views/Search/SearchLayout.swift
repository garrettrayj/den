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

    let hideRead: Bool
    let query: String

    var body: some View {
        GeometryReader { geometry in
            if query == "" {
                SplashNote(
                    title: "Searching \(profile.wrappedName)",
                    symbol: "magnifyingglass"
                )
            } else {
                WithItems(
                    scopeObject: profile,
                    readFilter: hideRead ? false : nil,
                    includeExtras: true,
                    searchQuery: query
                ) { items in
                    if items.isEmpty {
                        if hideRead {
                            SplashNote(title: "No Unread Results")
                        } else {
                            SplashNote(title: "No Results")
                        }
                    } else {
                        ScrollView(.vertical) {
                            BoardView(geometry: geometry, list: Array(items)) { item in
                                if item.feedData?.feed?.wrappedPreviewStyle == .expanded {
                                    FeedItemExpanded(item: item, profile: profile)
                                } else {
                                    FeedItemCompressed(item: item, profile: profile)
                                }
                            }.modifier(MainBoardModifier())
                        }
                        .edgesIgnoringSafeArea(.horizontal)
                    }
                }
            }
        }
    }
}
