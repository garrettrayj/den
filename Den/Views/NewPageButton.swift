//
//  NewPageButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewPageButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var currentProfile: Profile?

    var body: some View {
        Button {
            Task {
                guard let profile = currentProfile else { return }
                _ = Page.create(
                    in: viewContext,
                    profile: profile,
                    prepend: true
                )
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        } label: {
            Label {
                Text("New Page", comment: "Button label.")
            } icon: {
                Image(systemName: "folder.badge.plus")
            }
        }
        .accessibilityIdentifier("new-page-button")
        .keyboardShortcut("n", modifiers: [.command, .shift])
    }
}
