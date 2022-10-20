//
//  BlendView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendView: View {
    @ObservedObject var page: Page

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var frameSize: CGSize

    var body: some View {
        if visibleItems.isEmpty {
            AllReadStatusView(hiddenItemCount: page.previewItems.read().count)
        } else {
            ScrollView(.vertical) {
                BoardView(width: frameSize.width, list: visibleItems) { item in
                    FeedItemPreviewView(item: item, refreshing: $refreshing)
                }
                .modifier(TopLevelBoardPaddingModifier())
                .clipped()
            }
        }
    }

    private var visibleItems: [Item] {
        page.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
