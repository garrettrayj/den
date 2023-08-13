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
                Image(systemName: "square.slash")
            }
        } description: {
            Text(
                """
                Open a syndication link, drag and drop a URL, \
                use the Safari extension to discover feeds on websites, or…
                """,
                comment: "Empty page guidance."
            )
        } actions: {
            Button {
                showingNewFeedSheet = true
            } label: {
                Label {
                    Text("Enter a Web Address", comment: "Button label.")
                } icon: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}
