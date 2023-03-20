//
//  DeckLayoutView.swift
//  Den
//
//  Created by Garrett Johnson on 3/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeckLayoutView: View {
    @ObservedObject var page: Page

    @Binding var previewStyle: PreviewStyle

    let items: FetchedResults<Item>
    let pageGeometry: GeometryProxy

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top, spacing: 0) {
                ForEach(page.feedsArray) { feed in
                    DeckColumnView(
                        feed: feed,
                        isFirst: page.feedsArray.first == feed,
                        isLast: page.feedsArray.last == feed,
                        items: items.forFeed(feed: feed),
                        previewStyle: previewStyle,
                        pageGeometry: pageGeometry
                    )
                }
            }
        }
        .edgesIgnoringSafeArea([.bottom, .top])
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
        .id("deck_\(page.id?.uuidString ?? "na")_\(previewStyle)")
    }
}
