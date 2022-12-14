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

    let width: CGFloat

    var body: some View {
        if visibleItems.isEmpty {
            AllReadStatusView(hiddenItemCount: page.previewItems.read().count)
        } else {
            ScrollView(.vertical) {
                BoardView(width: width, list: visibleItems) { item in
                    FeedItemPreviewView(item: item)
                }
            }
        }
    }

    private var visibleItems: [Item] {
        page.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
