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
    @ObservedObject var profile: Profile

    @ViewBuilder var content: Content

    var body: some View {
        Group {
            if item.feedData?.feed?.browserView == true {
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
            if item.feedData?.feed?.browserView == true {
                NavigationLink(value: DetailPanel.item(item)) {
                    Text("View")
                }
            } else {
                Button {
                    if let url = item.link {
                        openInBrowser(url: url)
                        Task {
                            await HistoryUtility.markItemRead(item: item)
                        }
                    }
                } label: {
                    Label("Open in Browser", systemImage: "link")
                }
            }

            if let link = item.link {
                ShareLink(item: link)
            }
        }
    }

    private func openInBrowser(url: URL) {
        if useInbuiltBrowser {
            SafariUtility.openLink(
                url: url,
                controlTintColor: profile.tintUIColor ?? .tintColor,
                readerMode: item.feedData?.feed?.readerMode ?? false
            )
        } else {
            openURL(url)
        }
    }
}
