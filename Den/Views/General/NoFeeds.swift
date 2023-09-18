//
//  NoFeeds.swift
//  Den
//
//  Created by Garrett Johnson on 1/31/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NoFeeds: View {
    @Binding var showingNewFeedSheet: Bool

    var body: some View {
        ContentUnavailableView {
            Label {
                Text("No Feeds", comment: "Empty page title.")
            } icon: {
                Image(systemName: "circle.slash")
            }
        } description: {
            #if os(macOS)
            Text(
                """
                Open a syndication link, drag a URL to the page list, \
                use the Safari extension to discover feeds on websites, \
                or press \(Image(systemName: "command")) + F to add a new feed by entering address.
                """,
                comment: "Empty page guidance."
            )
            #else
            if UIDevice.current.userInterfaceIdiom == .phone {
                Text(
                    """
                    Open syndication links, \
                    use the Safari extension to discover feeds on websites, or…
                    """,
                    comment: "Empty page guidance (no drag-n-drop)."
                )
            } else {
                Text(
                    """
                    Open syndication links, drag and drop URLs on the page list, \
                    use the Safari extension to discover feeds on websites, or…
                    """,
                    comment: "Empty page guidance."
                )
            }
            #endif
        } actions: {
            Button {
                showingNewFeedSheet = true
            } label: {
                Label {
                    Text("Enter a Web Address", comment: "Button label.")
                } icon: {
                    Image(systemName: "note.text.badge.plus")
                }
            }
        }
    }
}
