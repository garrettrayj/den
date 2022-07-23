//
//  PageTimelineView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageTimelineView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var page: Page

    @Binding var hideRead: Bool

    var frameSize: CGSize

    var body: some View {
        if page.previewItems.isEmpty {
            StatusBoxView(message: Text("Timeline Empty"), symbol: "clock")
        } else {
            BoardView(width: frameSize.width, list: visibleItems) { item in
                FeedItemPreviewView(item: item)
            }
            .padding()
        }
    }

    private var visibleItems: [Item] {
        page.limitedItemsArray.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
