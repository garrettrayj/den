//
//  ItemActionView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemActionView<Content: View>: View {
    @Environment(\.useInbuiltBrowser) private var useInbuiltBrowser
    @Environment(\.openURL) private var openURL

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            if feed.browserView == true {
                Button {
                    if let url = item.link {
                        openInBrowser(url: url)
                        Task {
                            await HistoryUtility.markItemRead(item: item)
                        }
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
        .contextMenu {
            if let link = item.link {
                if feed.browserView == true {
                    NavigationLink(value: DetailPanel.item(item)) {
                        Text("View Item")
                    }
                } else {
                    Button {
                        openInBrowser(url: link)
                        Task {
                            await HistoryUtility.markItemRead(item: item)
                        }
                    } label: {
                        Label("Open in Browser", systemImage: "link")
                    }
                }
                Divider()

                ShareLink(item: link)
                Button {
                    UIPasteboard.general.url = link
                } label: {
                    Label("Copy Link", systemImage: "doc.on.doc")
                }
            }
        }
    }

    private func openInBrowser(url: URL) {
        if useInbuiltBrowser {
            SafariUtility.openLink(
                url: url,
                controlTintColor: profile.tintUIColor ?? .tintColor,
                readerMode: feed.readerMode
            )
        } else {
            openURL(url)
        }
    }
}
