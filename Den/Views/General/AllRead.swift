//
//  AllRead.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
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
                    Turn off filter \(Image(systemName: "line.3.horizontal.decrease")) to show hidden items.
                    """,
                    comment: "All read guidance."
                )
            }
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
