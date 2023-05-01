//
//  ShowcaseLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ShowcaseLayout: View {
    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    let hideRead: Bool

    let items: [Item]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                    ForEach(page.feedsArray) { feed in
                        ShowcaseSection(
                            feed: feed,
                            profile: profile,
                            items: items.forFeed(feed: feed),
                            geometry: geometry
                        )
                    }
                }
            }
            .id("ShowcaseLayoutSroll_\(page.id?.uuidString ?? "NoID")")
            .edgesIgnoringSafeArea(.horizontal)
        }
    }
}
