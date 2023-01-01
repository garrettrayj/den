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
    @Environment(\.useInbuiltBrowser) private var useInbuiltBrowser
    @Environment(\.openURL) private var openURL
    @ObservedObject var item: Item

    @ViewBuilder var content: Content

    var body: some View {
        if item.feedData?.feed?.browserView == true {
            Button {
                if useInbuiltBrowser {
                    SafariUtility.openLink(
                        url: item.link,
                        readerMode: item.feedData?.feed?.readerMode ?? false
                    )
                } else {
                    if let url = item.link {
                        openURL(url)
                    }
                }
                Task {
                    await SyncUtility.markItemRead(item: item)
                }
            } label: {
                content
            }
            .buttonStyle(ItemButtonStyle(read: item.read))
        } else {
            NavigationLink(value: DetailPanel.item(item)) {
                content
            }
            .buttonStyle(ItemButtonStyle(read: item.read))
        }
    }
}
