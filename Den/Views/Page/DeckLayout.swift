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

    @Binding var hideRead: Bool

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
                            items: items.forFeed(feed: feed),
                            pageGeometry: geometry,
                            hideRead: hideRead
                        )
                    }
                }
                .safeAreaInset(edge: .leading, alignment: .top, spacing: 0) {
                    HStack { Text(verbatim: "M").font(.title3).padding(.vertical, 12).foregroundStyle(.clear) }
                        .frame(width: geometry.safeAreaInsets.leading)
                        .background(.regularMaterial)
                        .background(.tertiary)
                        .padding(.top, geometry.safeAreaInsets.top)
                }
                .safeAreaInset(edge: .trailing, alignment: .top, spacing: 0) {
                    HStack {
                        Text(verbatim: "M").font(.title3).padding(.vertical, 12).foregroundStyle(.clear) }
                        .frame(width: geometry.safeAreaInsets.trailing)
                        .background(.regularMaterial)
                        .background(.tertiary)
                        .padding(.top, geometry.safeAreaInsets.top)
                }
            }
            .id("DeckLayoutSroll_\(page.id?.uuidString ?? "NoID")")
            .edgesIgnoringSafeArea(.all)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            #endif
        }
    }
}
