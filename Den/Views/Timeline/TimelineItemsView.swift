//
//  TimelineItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/26/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TimelineItemsView: View {
    var profile: Profile

    @Binding var hideRead: Bool

    var frameSize: CGSize

    var body: some View {
        if profile.previewItems.unread().isEmpty && hideRead == true {
            AllReadView(hiddenItemCount: profile.previewItems.read().count).frame(height: frameSize.height - 8)
        } else {
            BoardView(width: frameSize.width, list: visibleItems) { item in
                FeedItemPreviewView(item: item)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .padding(.top, 8)
        }
    }

    private var visibleItems: [Item] {
        profile.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
