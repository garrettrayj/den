//
//  NoSearchResults.swift
//  Den
//
//  Created by Garrett Johnson on 12/14/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct NoSearchResults: View {
    @Binding var searchQuery: String
    
    var body: some View {
        ContentUnavailable {
            Label {
                Text(
                    "No Results for “\(searchQuery)”",
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
