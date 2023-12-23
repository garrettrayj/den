//
//  NoSearchResults.swift
//  Den
//
//  Created by Garrett Johnson on 12/14/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct NoSearchResults: View {
    var body: some View {
        ContentUnavailable {
            Label {
                Text(
                    "No Results",
                    comment: "No search results message title."
                )
            } icon: {
                Image(systemName: "magnifyingglass")
            }
        } description: {
            Text(
                "Check the spelling or try a new search.",
                comment: "No search results guidance."
            )
        }
    }
}
