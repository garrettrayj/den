//
//  PageSettingsButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageSettingsButton: View {
    @Binding var showingSettings: Bool

    var body: some View {
        Button {
            showingSettings = true
        } label: {
            Label {
                Text("Page Settings", comment: "Button label.")
            } icon: {
                Image(systemName: "wrench")
            }
        }
        .accessibilityIdentifier("ShowPageSettings")
    }
}
