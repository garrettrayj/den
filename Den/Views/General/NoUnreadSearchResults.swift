//
//  NoUnreadSearchResults.swift
//  Den
//
//  Created by Garrett Johnson on 12/14/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct NoUnreadSearchResults: View {
    @Binding var searchQuery: String
    
    var body: some View {
        ContentUnavailable {
            Label {
                Text(
                    "No Unread Results for “\(searchQuery)”",
                    comment: "No unread search results title."
                )
            } icon: {
                Image(systemName: "magnifyingglass")
            }
        } description: {
            Text(
                """
                Turn off filter to show hidden items.
                """,
                comment: "No unread search results guidance."
            )
        }
    }
}
