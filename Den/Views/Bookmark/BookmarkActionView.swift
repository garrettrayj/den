//
//  BookmarkActionView.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SafariServices
import SwiftUI

struct BookmarkActionView<Content: View>: View {
    #if os(iOS)
    @Environment(\.openURLInSafariView) private var openURLInSafariView
    #endif
    @Environment(\.openURL) private var openURL

    @ObservedObject var bookmark: Bookmark

    @ViewBuilder var content: Content
    
    @AppStorage("Viewer") private var viewer: ViewerOption = .builtInViewer

    var body: some View {
        ZStack {
            #if os(macOS)
            if viewer == .webBrowser {
                Button {
                    guard let url = bookmark.link else { return }
                    openURL(url)
                } label: {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            } else {
                NavigationLink(value: SubDetailPanel.bookmark(bookmark.objectID.uriRepresentation())) {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            }
            #else
            if viewer == .webBrowser {
                Button {
                    guard let url = bookmark.link else { return }
                    openURL(url)
                } label: {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            } else if viewer == .safariView {
                Button {
                    guard let url = bookmark.link else { return }
                    
                    openURLInSafariView(url, bookmark.feed?.readerMode)
                } label: {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            } else {
                NavigationLink(value: SubDetailPanel.bookmark(bookmark.objectID.uriRepresentation())) {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            }
            #endif
        }
        .buttonStyle(PreviewButtonStyle(read: .constant(false), roundedBottom: true, roundedTop: true))
        .drawingGroup()
        .accessibilityIdentifier("BookmarkAction")
        .contextMenu {
            UnbookmarkButton(bookmark: bookmark)
            Divider()
            if let url = bookmark.link {
                if viewer != .builtInViewer {
                    NavigationLink(
                        value: SubDetailPanel.bookmark(bookmark.objectID.uriRepresentation())
                    ) {
                        Label {
                            Text("Open in Viewer", comment: "Button label.")
                        } icon: {
                            Image(systemName: "doc.text")
                        }
                    }
                }
                #if os(iOS)
                if viewer != .safariView {
                    SafariViewButton(
                        url: url,
                        entersReaderIfAvailable: bookmark.feed?.readerMode ?? false
                    )
                }
                #endif
                if viewer != .webBrowser {
                    SystemBrowserButton(url: url)
                }
                CopyLinkButton(url: url)
                ShareButton(item: url)
            }
            if let feedObjectURL = bookmark.feed?.objectID.uriRepresentation() {
                Divider()
                GoToFeedNavLink(feedObjectURL: feedObjectURL)
            }
        }
    }
}
