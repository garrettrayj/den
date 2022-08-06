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

    let item: Item

    @ViewBuilder var content: Content

    @State var showingItemView: Bool = false

    var body: some View {
        VStack {
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
                Button {
                    showingItemView = true
                    syncManager.markItemRead(item: item)
                } label: {
                    content
                }
                .buttonStyle(ItemButtonStyle(read: item.read))
                .background(
                    NavigationLink(isActive: $showingItemView, destination: {
                        ItemView(item: item)
                    }, label: {
                        EmptyView()
                    })
                )
            }
        }
    }
}
