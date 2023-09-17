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
    @Binding var showingNewProfileSheet: Bool

    var body: some View {
        Button {
            showingNewProfileSheet = true
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
