//
//  BlendView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendView: View {
    let page: Page

    @Binding var hideRead: Bool
    
    let frameSize: CGSize

    var body: some View {
        if visibleItems.isEmpty {
            AllReadStatusView(hiddenItemCount: page.previewItems.read().count)
        } else {
            ScrollView(.vertical) {
                BoardView(width: frameSize.width, list: visibleItems) { item in
                    FeedItemPreviewView(item: item)
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
