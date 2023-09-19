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
    @Environment(\.userTint) private var userTint
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var bookmark: Bookmark
    @ObservedObject var feed: Feed
    @ObservedObject var profile: Profile

    @ViewBuilder var content: Content

    var body: some View {
        Group {
            if feed.browserView == true, let url = bookmark.link {
                OpenInBrowserButton(url: url, readerMode: feed.readerMode) {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
                .buttonStyle(ItemButtonStyle(read: false))
                .accessibilityIdentifier("BookmarkAction")
            } else {
                NavigationLink(value: SubDetailPanel.bookmark(bookmark)) {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
                .buttonStyle(ItemButtonStyle(read: false))
                .accessibilityIdentifier("BookmarkAction")
            }
        }
        .contextMenu {
            NavigationLink(value: SubDetailPanel.bookmark(bookmark)) {
                Label {
                    Text("Go to Item", comment: "Context Button label.")
                } icon: {
                    Image(systemName: "chevron.forward")
                }
            }

            if let link = bookmark.link {
                OpenInBrowserButton(url: link, readerMode: feed.readerMode) {
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

            DeleteBookmarkButton(bookmark: bookmark)
        }
    }
}
