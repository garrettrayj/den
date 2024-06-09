//
//  UntagButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct UntagButton: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var bookmark: Bookmark
    
    var callback: (() -> Void)?

    var body: some View {
        Button(role: .destructive) {
            guard let tag = bookmark.tag else { return }
            modelContext.delete(bookmark)
            do {
                try modelContext.save()
                callback?()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Label {
                Text("Untag", comment: "Button label.")
            } icon: {
                Image(systemName: "tag.slash")
            }
        }
        .help(Text("Remove Bookmark", comment: "Button help text."))
        .accessibilityIdentifier("Untag")
    }
}
