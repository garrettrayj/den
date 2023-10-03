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
        if let url = bookmark.link {
            Group {
                if useSystemBrowser {
                    Button {
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
            .buttonStyle(ItemButtonStyle(read: .constant(false)))
            .accessibilityIdentifier("BookmarkAction")
            .contextMenu {
                NavigationLink(value: SubDetailPanel.bookmark(bookmark)) {
                    Label {
                        Text("Go to Item", comment: "Context Button label.")
                    } icon: {
                        Image(systemName: "chevron.forward")
                    }
                }
                Button {
                    PasteboardUtility.copyURL(url: url)
                } label: {
                    Label {
                        Text("Copy Link", comment: "Context Button label.")
                    } icon: {
                        Image(systemName: "doc.on.doc")
                    }
                }
                ShareButton(url: url)
                DeleteBookmarkButton(bookmark: bookmark)
            }
        }
    }
}
