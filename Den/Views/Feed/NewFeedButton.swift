//
//  NewFeedButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NewFeedButton: View {
    @SceneStorage("ShowingNewFeedSheet") private var showingNewFeedSheet: Bool = false

    var body: some View {
        Button {
            showingNewFeedSheet = true
        } label: {
            Label {
                Text("New Feed", comment: "Button label.")
            } icon: {
                Image(systemName: "note.text.badge.plus")
            }
        }
        .keyboardShortcut("k", modifiers: [.command])
        .accessibilityIdentifier("NewFeed")
    }
}
