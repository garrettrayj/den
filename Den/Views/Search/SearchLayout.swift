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
    let previewStyle: PreviewStyle
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
                            SplashNote(title: "No Unread Items")
                        } else {
                            SplashNote(title: "No Results")
                        }
                    } else {
                        ScrollView(.vertical) {
                            BoardView(geometry: geometry, list: Array(items)) { item in
                                if previewStyle == .compressed {
                                    FeedItemCompressed(item: item, profile: profile, showExtraTag: true)
                                } else {
                                    FeedItemExpanded(item: item, profile: profile, showExtraTag: true)
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
