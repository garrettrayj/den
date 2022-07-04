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
        ScrollView(.vertical) { content }
    }

    @ViewBuilder
    var content: some View {
        if page.limitedItemsArray.isEmpty {
            StatusBoxView(
                message: Text("No Items"),
                caption: Text("Tap \(Image(systemName: "arrow.clockwise")) to refresh"),
                symbol: "questionmark.square.dashed"
            )
            .frame(height: frameSize.height - 60)
        } else if visibleItems.isEmpty {
            StatusBoxView(
                message: Text("No Unread Items"),
                caption: nil,
                symbol: "checkmark.circle"
            )
            .frame(height: frameSize.height - 60)
        } else {
            BoardView(width: frameSize.width, list: visibleItems) { item in
                FeedItemPreviewView(item: item)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private var visibleItems: [Item] {
        page.limitedItemsArray.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
