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

    @ViewBuilder var content: Content

    var body: some View {
        Group {
            if useSystemBrowser {
                Button {
                    guard let url = bookmark.link else { return }
                    openURL(url)
                } label: {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            } else {
                NavigationLink(value: SubDetailPanel.bookmark(bookmark)) {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            }
        }
        .buttonStyle(PreviewButtonStyle(read: .constant(false), roundedBottom: true, roundedTop: true))
        .accessibilityIdentifier("BookmarkAction")
        .contextMenu {
            UntagButton(bookmark: bookmark)
            SystemBrowserButton(url: $bookmark.link)
            CopyLinkButton(url: $bookmark.link)
            ShareButton(url: $bookmark.link)
        }
    }
}
