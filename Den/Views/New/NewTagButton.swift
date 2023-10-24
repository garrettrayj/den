//
//  NewTagButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct NewTagButton: View {
    @Binding var showingNewTagSheet: Bool

    var body: some View {
        Button {
            showingNewTagSheet = true
        } label: {
            Label {
                Text("New Tag", comment: "Button label.")
            } icon: {
                Image(systemName: "tag")
            }
        }
        .keyboardShortcut("n", modifiers: [.command, .option], localization: .withoutMirroring)
        .accessibilityIdentifier("NewTag")
    }
}
