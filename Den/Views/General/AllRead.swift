//
//  AllRead.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct AllRead: View {
    var largeDisplay: Bool = false

    var body: some View {
        if largeDisplay {
            ContentUnavailable {
                Label {
                    Text("All Read", comment: "Content unavailable title.")
                } icon: {
                    Image(systemName: "checkmark")
                }
            } description: {
                Text(
                    """
                    Turn off filter to show hidden items.
                    """,
                    comment: "All read guidance."
                )
            }
            .padding()
        } else {
            CompactContentUnavailable {
                Label {
                    Text("All Read", comment: "Card note title.")
                } icon: {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
