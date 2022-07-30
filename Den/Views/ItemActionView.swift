//
//  ItemActionView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemActionView<Content: View>: View {
    @EnvironmentObject var linkManager: LinkManager

    @ObservedObject var item: Item

    @ViewBuilder var content: Content

    var body: some View {
        VStack {
            if item.feedData?.feed?.browserView == true {
                Button {
                    linkManager.openLink(
                        url: item.link,
                        logHistoryItem: item,
                        readerMode: item.feedData?.feed?.readerMode ?? false
                    )
                    item.objectWillChange.send()
                } label: {
                    content
                }
            } else {
                NavigationLink {
                    ItemView(viewModel: ItemViewModel(item: item))
                        .onAppear {
                            linkManager.markItemRead(item: item)
                            item.objectWillChange.send()
                        }
                } label: {
                    content
                }
            }
        }.buttonStyle(ItemButtonStyle(read: item.read))
    }
}
