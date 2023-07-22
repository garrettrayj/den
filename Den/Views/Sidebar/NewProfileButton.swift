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

    @Binding var currentProfileID: String?

    var body: some View {
        Button {
            let newProfile = Profile.create(in: viewContext)
            do {
                try viewContext.save()
                currentProfileID = newProfile.id?.uuidString
            } catch let error as NSError {
                CrashUtility.handleCriticalError(error)
            }
        } label: {
            Label {
                Text("New Profile", comment: "Button label.").lineLimit(1)
            } icon: {
                Image(systemName: "person.crop.circle.badge.plus")
            }
        }
        .accessibilityIdentifier("NewProfile")
    }
}
