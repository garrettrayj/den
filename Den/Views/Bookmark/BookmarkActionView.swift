//
//  BookmarkActionView.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
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
            .buttonStyle(PreviewButtonStyle(read: .constant(false), roundedBottom: true))
            .accessibilityIdentifier("BookmarkAction")
            .contextMenu {
                UntagButton(bookmark: bookmark)
                Button {
                    openURL(url)
                } label: {
                    OpenInBrowserLabel()
                }
                Button {
                    PasteboardUtility.copyURL(url: url)
                } label: {
                    Label {
                        Text("Copy Link", comment: "Context Button label.")
                    } icon: {
                        Image(systemName: "link.circle")
                    }
                }
                ShareButton(url: url)
            }
        }
    }
}
