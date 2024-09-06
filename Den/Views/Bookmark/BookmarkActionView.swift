//
//  BookmarkActionView.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SafariServices
import SwiftUI

struct BookmarkActionView<Content: View>: View {
    @Environment(\.openURL) private var openURL
    #if os(iOS)
    @Environment(\.openURLInSafariView) private var openURLInSafariView
    #endif
    @Environment(\.preferredViewer) private var preferredViewer

    @ObservedObject var bookmark: Bookmark

    @ViewBuilder var content: Content

    var body: some View {
        Group {
            switch preferredViewer {
            case .builtInViewer:
                NavigationLink(value: SubDetailPanel.bookmark(bookmark.objectID.uriRepresentation())) {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            case .webBrowser:
                Button {
                    guard let url = bookmark.link else { return }
                    openURL(url)
                } label: {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            #if os(iOS)
            case .safariView:
                Button {
                    guard let url = bookmark.link else { return }
                    openURLInSafariView(url, bookmark.feed?.readerMode)
                } label: {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            #endif
            }
        }
        .buttonStyle(PreviewButtonStyle(read: .constant(false), roundedBottom: true, roundedTop: true))
        .accessibilityIdentifier("BookmarkAction")
        .contextMenu {
            UnbookmarkButton(bookmark: bookmark)
            Divider()
            if let url = bookmark.link {
                if preferredViewer != .builtInViewer {
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
                if preferredViewer != .safariView {
                    SafariViewButton(
                        url: url,
                        entersReaderIfAvailable: bookmark.feed?.readerMode ?? false
                    )
                }
                #endif
                if preferredViewer != .webBrowser {
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
