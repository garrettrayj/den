//
//  DeleteBookmarkButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteBookmarkButton: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var bookmark: Bookmark

    var body: some View {
        Button(role: .destructive) {
            bookmark.item?.bookmarked = false
            modelContext.delete(bookmark)
        } label: {
            Label {
                Text("Delete Bookmark", comment: "Button label.")
            } icon: {
                Image(systemName: "bookmark").symbolVariant(.slash)
            }
        }
        .help(Text("Delete bookmark", comment: "Button help text."))
        .accessibilityIdentifier("Untag")
    }
}
