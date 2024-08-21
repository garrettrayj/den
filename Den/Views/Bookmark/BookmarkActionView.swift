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
    @Environment(\.self) private var environment
    @Environment(\.openURL) private var openURL

    @ObservedObject var bookmark: Bookmark

    @ViewBuilder var content: Content
    
    @AppStorage("AccentColor") private var accentColor: AccentColor = .coral
    @AppStorage("Viewer") private var viewer: ViewerOption = .builtInViewer

    var body: some View {
        ZStack {
            #if os(macOS)
            if viewer == .systemBrowser {
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
            if viewer == .systemBrowser {
                Button {
                    guard let url = bookmark.link else { return }
                    openURL(url)
                } label: {
                    content.modifier(DraggableBookmarkModifier(bookmark: bookmark))
                }
            } else if viewer == .inAppSafari {
                Button {
                    guard let url = bookmark.link else { return }
                    
                    InAppSafari.open(
                        url: url,
                        environment: environment,
                        accentColor: accentColor,
                        entersReaderIfAvailable: bookmark.feed?.readerMode ?? false
                    )
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
            if let url = bookmark.link {
                SystemBrowserButton(url: url)
                CopyAddressButton(url: url)
                ShareButton(item: url)
            }
            if let feedObjectURL = bookmark.feed?.objectID.uriRepresentation() {
                Divider()
                GoToFeedNavLink(feedObjectURL: feedObjectURL)
            }
        }
    }
}
