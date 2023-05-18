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
            statusText
            if let unreadText = unreadText {
                unreadText.foregroundColor(.secondary)
            }
        }
        .font(.caption)
        .lineLimit(1)
    }

    private var statusText: Text {
        if query.isEmpty {
            return Text("Enter a search term.")
        } else {
            if totalCount == 1 {
                return Text("Found \(totalCount) result for “\(query)”")
            } else {
                return Text("Found \(totalCount) results for “\(query)”")
            }
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
