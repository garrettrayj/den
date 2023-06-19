//
//  NewProfileButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewProfileButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Button {
            withAnimation {
                _ = Profile.create(in: viewContext)

                do {
                    try viewContext.save()
                } catch let error as NSError {
                    CrashUtility.handleCriticalError(error)
                }
            }
        } label: {
            Label {
                Text("New Profile", comment: "Button label.").lineLimit(1)
            } icon: {
                Image(systemName: "plus.circle")
            }
        }
        .accessibilityIdentifier("new-profile-button")
    }
}
