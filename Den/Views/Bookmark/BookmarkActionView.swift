//
//  BookmarkActionView.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BookmarkActionView<Content: View>: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var bookmark: Bookmark
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @ViewBuilder var content: Content

    var body: some View {
        Group {
            if feed.browserView == true {
                Button {
                    if let url = bookmark.link {
                        Task {
                            openInBrowser(url: url)
                        }
                    }
                } label: {
                    content
                }
                .buttonStyle(ItemButtonStyle(read: false))
                .accessibilityIdentifier("BookmarkAction")
            } else {
                NavigationLink(value: SubDetailPanel.bookmark(bookmark)) {
                    content
                }
                .buttonStyle(ItemButtonStyle(read: false))
                .accessibilityIdentifier("BookmarkAction")
            }
        }
        .contextMenu {
            if let link = bookmark.link {
                NavigationLink(value: SubDetailPanel.bookmark(bookmark)) {
                    Label {
                        Text("Go to Item", comment: "Context Button label.")
                    } icon: {
                        Image(systemName: "chevron.forward")
                    }
                }
                Button {
                    Task {
                        // await HistoryUtility.markItemRead(bookmark: item)
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
