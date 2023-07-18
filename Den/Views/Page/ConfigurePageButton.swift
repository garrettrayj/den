//
//  ConfigurePageButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ConfigurePageButton: View {
    @Binding var showingSettings: Bool

    var body: some View {
        Button {
            showingSettings = true
        } label: {
            Label {
                Text("Configure", comment: "Button label.")
            } icon: {
                Image(systemName: "hammer")
            }
        }
        .accessibilityIdentifier("ConfigurePage")
    }
}
