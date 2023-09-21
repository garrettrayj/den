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
                Open a syndication link, drag a URL onto the page list, \
                or go to “\(Image(systemName: "ellipsis.circle" )) > New Feed” to enter a web address. \
                Use the Safari extension to discover feeds on websites.
                """,
                comment: "No feeds guidance (Mac)."
            )
            .imageScale(.small)
            #else
            if UIDevice.current.userInterfaceIdiom == .phone {
                Text(
                    """
                    Open a syndication link or go to “\(Image(systemName: "ellipsis.circle" )) > New Feed” \
                    from the home/sidebar view to enter a web address. \
                    Use the Safari extension to discover feeds on websites.
                    """,
                    comment: "No feeds guidance (iPhone)."
                )
            } else {
                Text(
                    """
                    Open a syndication link, drag a URL onto the page list, \
                    or go to “\(Image(systemName: "ellipsis.circle" )) > New Feed” \
                    from the sidebar/home view to enter a web address. \
                    Use the Safari extension to discover feeds on websites.
                    """,
                    comment: "No feeds guidance (iPad)."
                )
            }
            #endif
        }
    }
}
