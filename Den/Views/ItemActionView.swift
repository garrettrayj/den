//
//  ItemActionView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemActionView<Content: View>: View {
    @EnvironmentObject private var syncManager: SyncManager

    @ObservedObject var item: Item

    @ViewBuilder var content: Content

    var body: some View {
        if item.feedData?.feed?.browserView == true {
            Button {
                syncManager.openLink(
                    url: item.link,
                    logHistoryItem: item,
                    readerMode: item.feedData?.feed?.readerMode ?? false
                )
            } label: {
                content
            }.buttonStyle(ItemButtonStyle(read: item.read))
        } else {
            NavigationLink {
                ItemView(item: item)
            } label: {
                content
            }.buttonStyle(ItemButtonStyle(read: item.read))
        }
    }
}
