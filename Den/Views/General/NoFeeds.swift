//
//  NoFeeds.swift
//  Den
//
//  Created by Garrett Johnson on 1/31/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NoFeeds: View {
    var symbol = "folder"

    var body: some View {
        ContentUnavailable {
            Label {
                Text("No Feeds", comment: "Content unavailable title.")
            } icon: {
                Image(systemName: symbol)
            }
        } description: {
            Text(
                """
                Open a syndication link or drag a feed web address onto a folder in the sidebar. \
                Use the Safari extension to discover feeds on websites.
                """,
                comment: "No feeds guidance."
            )
            .imageScale(.small)
        } actions: {
            NewFeedButton()
        }
    }
}
