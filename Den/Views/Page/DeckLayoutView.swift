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
    let page: Page
    let hideRead: Bool
    let previewStyle: PreviewStyle

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                WithItems(
                    scopeObject: page,
                    sortDescriptors: [
                        NSSortDescriptor(keyPath: \Item.feedData?.id, ascending: false),
                        NSSortDescriptor(keyPath: \Item.published, ascending: false)
                    ],
                    readFilter: hideRead ? false : nil
                ) { items in
                    LazyHStack(alignment: .top, spacing: 0) {
                        ForEach(page.feedsArray) { feed in
                            DeckColumnView(
                                feed: feed,
                                isFirst: page.feedsArray.first == feed,
                                isLast: page.feedsArray.last == feed,
                                items: items.forFeed(feed: feed),
                                previewStyle: previewStyle,
                                pageGeometry: geometry
                            )
                        }
                    }
                }
            }
            .edgesIgnoringSafeArea([.bottom, .top])
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
