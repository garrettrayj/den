//
//  SearchStatus.swift
//  Den
//
//  Created by Garrett Johnson on 4/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SearchStatus: View {
    let unreadCount: Int
    let totalCount: Int
    let query: String

    var body: some View {
        ViewThatFits {
            HStack(spacing: 0) {
                if let unreadText = unreadText {
                    statusText + Text(verbatim: ", ") + unreadText
                } else {
                    statusText
                }
            }
            VStack {
                statusText
                if let unreadText = unreadText {
                    unreadText.foregroundColor(.secondary)
                }
            }
        }
        .font(.caption)
        .lineLimit(1)
    }

    private var statusText: Text {
        if query.isEmpty {
            return Text("Enter a search term.", comment: "Search guidance.")
        } else {
            if totalCount == 0 {
                return Text(
                    "No results found for “\(query)”",
                    comment: "Search status (zero results)."
                )
            } else if totalCount == 1 {
                return Text(
                    "Found 1 result for “\(query)”",
                    comment: "Search status (singular result)."
                )
            } else {
                return Text(
                    "Found \(totalCount) results for “\(query)”",
                    comment: "Search status (plural results)."
                )
            }
        }
    }

    private var unreadText: Text? {
        if query.isEmpty || totalCount == 0 {
            return nil
        } else {
            return Text("\(unreadCount) Unread", comment: "Status message.")
        }
    }
}
