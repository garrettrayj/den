//
//  AllRead.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AllRead: View {
    var largeDisplay: Bool = false
    
    var body: some View {
        if largeDisplay {
            ContentUnavailableView {
                Label {
                    Text("All Read")
                } icon: {
                    Image(systemName: "checkmark.circle")
                }
            } description: {
                Text("Turn off filtering to show hidden items.")
            }
            .frame(maxWidth: .infinity)
        } else {
            CardNote(
                Text("All Read", comment: "No unread items message."),
                icon: { Image(systemName: "checkmark.circle") }
            )
        }
    }
}
