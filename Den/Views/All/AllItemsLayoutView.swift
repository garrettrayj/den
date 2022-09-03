//
//  AllItemsLayoutView.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AllItemsLayoutView: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var frameSize: CGSize

    var body: some View {
        ScrollView(.vertical) {
            BoardView(width: frameSize.width, list: visibleItems) { item in
                FeedItemPreviewView(item: item, refreshing: $refreshing)
            }
            .padding()
            .clipped()
        }
    }

    private var visibleItems: [Item] {
        profile.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
