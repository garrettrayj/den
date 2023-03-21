//
//  InboxLayoutView.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct InboxLayoutView: View {
    @ObservedObject var profile: Profile

    let hideRead: Bool
    let previewStyle: PreviewStyle

    var body: some View {
        WithItems(
            scopeObject: profile,
            readFilter: hideRead ? false : nil
        ) { items in
            if profile.feedsArray.isEmpty {
                NoFeedsView()
            } else if items.isEmpty {
                AllReadSplashNoteView()
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        BoardView(width: geometry.size.width, list: Array(items)) { item in
                            if previewStyle == .compressed {
                                FeedItemCompressedView(item: item)
                            } else {
                                FeedItemExpandedView(item: item)
                            }
                        }.modifier(MainBoardModifier())
                    }
                }
            }
        }
    }
}
