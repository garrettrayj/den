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
        VStack {
            ViewThatFits {
                HStack(spacing: 4) {
                    statusText
                    if let unreadText = unreadText {
                        Text("－ ") + unreadText.foregroundColor(Color(.secondaryLabel))
                    }
                }
                VStack {
                    statusText
                    if let unreadText = unreadText {
                        unreadText.foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        }
        .font(.caption)
        .lineLimit(1)
    }

    private var statusText: Text {
        if query.isEmpty {
            return Text("Enter a search term.")
        } else {
            return Text("Found \(totalCount) results for “\(query)”")
        }
    }

    private var unreadText: Text? {
        if query.isEmpty || totalCount == 0 {
            return nil
        } else {
            return Text("\(unreadCount) Unread")
        }
    }
}
