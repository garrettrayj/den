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
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var item: Item
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @ViewBuilder var content: Content

    var body: some View {
        Group {
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
                .accessibilityIdentifier("ItemAction")
            } else {
                NavigationLink(value: SubDetailPanel.item(item)) {
                    content
                }
                .buttonStyle(ItemButtonStyle(read: item.read))
                .accessibilityIdentifier("ItemAction")
            }
        }
        .contextMenu {
            if let link = item.link {

                Button {
                    Task {
                        await HistoryUtility.toggleReadUnread(items: [item])
                    }
                } label: {
                    if item.read {
                        Label {
                            Text("Mark Unread", comment: "Button label.")
                        } icon: {
                            Image(systemName: "checkmark.circle.badge.xmark")
                        }
                    } else {
                        Label {
                            Text("Mark Read", comment: "Button label.")
                        } icon: {
                            Image(systemName: "checkmark.circle")
                        }
                    }
                }

                NavigationLink(value: SubDetailPanel.item(item)) {
                    Label {
                        Text("Go to Item", comment: "Context Button label.")
                    } icon: {
                        Image(systemName: "chevron.forward")
                    }
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
                        Text("Copy Link", comment: "Context Button label.")
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
                controlTintColor: profile.tintColor,
                readerMode: feed.readerMode
            )
        }
        #endif
    }
}
