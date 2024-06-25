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

    @Bindable var bookmark: Bookmark

    @ViewBuilder var content: Content
    
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

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
            if let url = bookmark.link {
                SystemBrowserButton(url: url)
                CopyAddressButton(url: url)
                ShareButton(item: url)
            }
        }
    }
}
