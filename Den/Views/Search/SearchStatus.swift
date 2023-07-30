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
    let resultCount: Int
    let query: String

    var body: some View {
        statusText.font(.caption).lineLimit(1)
    }

    private var statusText: Text {
        if query.isEmpty {
            return Text("Enter a search term.", comment: "Search guidance.")
        } else {
            if resultCount == 0 {
                return Text(
                    "No results found for “\(query)”",
                    comment: "Search status (zero results)."
                )
            } else if resultCount == 1 {
                return Text(
                    "Found 1 result for “\(query)”",
                    comment: "Search status (singular result)."
                )
            } else {
                return Text(
                    "Found \(resultCount) results for “\(query)”",
                    comment: "Search status (plural results)."
                )
            }
        }
    }
}
