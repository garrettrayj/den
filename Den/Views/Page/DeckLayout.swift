//
//  DeckLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeckLayout: View {
    @ObservedObject var page: Page
    @ObservedObject var profile: Profile

    let hideRead: Bool

    let items: FetchedResults<Item>

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: 0) {
                    ForEach(page.feedsArray) { feed in
                        DeckColumn(
                            feed: feed,
                            profile: profile,
                            isFirst: page.feedsArray.first == feed,
                            isLast: page.feedsArray.last == feed,
                            items: items.forFeed(feed: feed).visibilityFiltered(hideRead ? false : nil),
                            pageGeometry: geometry
                        )
                    }
                }
                .safeAreaInset(edge: .leading, alignment: .top, spacing: 0) {
                    if geometry.safeAreaInsets.leading > 0 {
                        HStack {
                            Text("M").font(.title3).hidden()
                        }
                        .modifier(PinnedSectionHeaderModifier())
                        .padding(.top, geometry.safeAreaInsets.top)
                        .frame(width: geometry.safeAreaInsets.leading)
                    }
                }
                .safeAreaInset(edge: .trailing, alignment: .top, spacing: 0) {
                    if geometry.safeAreaInsets.trailing > 0 {
                        HStack {
                            Text("M").font(.title3).hidden()
                        }
                        .modifier(PinnedSectionHeaderModifier())
                        .padding(.top, geometry.safeAreaInsets.top)
                        .frame(width: geometry.safeAreaInsets.trailing)
                    }
                }
            }
            .id("DeckLayoutSroll_\(page.id?.uuidString ?? "NoID")")
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
