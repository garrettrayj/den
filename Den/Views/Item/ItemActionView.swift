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
    @Environment(\.openURL) private var openURL
    @Environment(\.profileTint) private var profileTint
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            if feed.browserView == true {
                Button {
                    if let url = item.link {
                        Task {
                            await HistoryUtility.markItemRead(item: item)
                            openInBrowser(url: url)
                        }
                    }
                } label: {
                    content
                }
                .buttonStyle(ItemButtonStyle(read: item.read))
            } else {
                NavigationLink(value: SubDetailPanel.item(item)) {
                    content
                }
                .buttonStyle(ItemButtonStyle(read: item.read))
            }
        }
        .contextMenu {
            if let link = item.link {
                NavigationLink(value: SubDetailPanel.item(item)) {
                    Text("Go to Item", comment: "Context menu button label.")
                }
                Button {
                    Task {
                        await HistoryUtility.markItemRead(item: item)
                        openInBrowser(url: link)
                    }
                } label: {
                    OpenInBrowserLabel()
                }
                Button {
                    PasteboardUtility.copyURL(url: link)
                } label: {
                    Label {
                        Text("Copy Link", comment: "Context menu button label.")
                    } icon: {
                        Image(systemName: "doc.on.doc")
                    }
                }
                ShareButton(url: link)
            }
        }
    }

    private func openInBrowser(url: URL) {
        #if os(macOS)
        openURL(url)
        #else
        if useSystemBrowser {
            openURL(url)
        } else {
            BuiltInBrowser.openURL(
                url: url,
                controlTintColor: profileTint,
                readerMode: feed.readerMode
            )
        }
        #endif
    }
}
