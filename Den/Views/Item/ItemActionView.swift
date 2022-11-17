//
//  ItemActionView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI
import SafariServices

struct ItemActionView<Content: View>: View {
    @Environment(\.persistentContainer) private var container
    
    @ObservedObject var item: Item

    @ViewBuilder var content: Content

    var body: some View {
        if item.feedData?.feed?.browserView == true {
            Button {
                SafariUtility.openLink(
                    url: item.link,
                    readerMode: item.feedData?.feed?.readerMode ?? false
                )
                Task {
                    await SyncUtility.markItemRead(container: container, item: item)
                }
            } label: {
                content
            }
            .buttonStyle(ItemButtonStyle(read: item.read))
        } else {
            NavigationLink(value: ItemPanel.item(item)) {
                content
            }
            .buttonStyle(ItemButtonStyle(read: item.read))
        }
    }
}
