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

    var frameSize: CGSize

    var body: some View {
        ScrollView(.vertical) {
            if visibleItems.isEmpty {
                AllReadView(hiddenItemCount: page.previewItems.read().count).frame(height: frameSize.height - 8)
            } else {
                BoardView(width: frameSize.width, list: visibleItems) { item in
                    FeedItemPreviewView(item: item)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .padding(.top, 8)
            }
        }
    }

    private var visibleItems: [Item] {
        page.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
