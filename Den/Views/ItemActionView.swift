//
//  ItemActionView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemActionView<Content: View>: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item

    @ViewBuilder var content: Content

    var body: some View {
        if item.feedData?.feed?.browserView == true {
            Button {
                SyncManager.openLink(
                    context: viewContext,
                    url: item.link,
                    logHistoryItem: item,
                    readerMode: item.feedData?.feed?.readerMode ?? false
                )
            } label: {
                content
            }.buttonStyle(ItemButtonStyle(read: item.read))
        } else {
            NavigationLink(value: DetailPanel.item(item.id)) {
                content
            }.buttonStyle(ItemButtonStyle(read: item.read))
        }
    }
}
