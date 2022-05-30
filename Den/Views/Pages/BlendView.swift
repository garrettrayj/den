//
//  BlendView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var page: Page

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
            .frame(height: frameSize.height)
        } else if visibleItems.isEmpty {
            StatusBoxView(
                message: Text("No Unread Items"),
                caption: Text("You're all caught up"),
                symbol: "checkmark.circle"
            )
            .frame(height: frameSize.height)
        } else {
            BoardView(width: frameSize.width, list: visibleItems) { item in
                BlendItemView(item: item)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 38)
        }
    }

    private var visibleItems: [Item] {
        page.limitedItemsArray.filter { item in
            profileManager.activeProfile?.hideReadItems == true ? item.read == false : true
        }
    }
}
