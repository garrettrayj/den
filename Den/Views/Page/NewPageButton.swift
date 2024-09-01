//
//  NewPageButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NewPageButton: View {
    @SceneStorage("ShowingNewPageSheet") private var showingNewPageSheet = false

    var body: some View {
        Button {
            showingNewPageSheet = true
        } label: {
            Label {
                Text("New Folder", comment: "Button label.")
            } icon: {
                Image(systemName: "folder.badge.plus")
            }
        }
        .keyboardShortcut("n", modifiers: [.command, .shift])
        .accessibilityIdentifier("NewPage")
    }
}
