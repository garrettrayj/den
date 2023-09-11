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
    @Binding var showingPageConfiguration: Bool

    var body: some View {
        Button {
            showingPageConfiguration = true
        } label: {
            Label {
                Text("Configure", comment: "Button label.")
            } icon: {
                Image(systemName: "slider.horizontal.3")
            }
        }
        .accessibilityIdentifier("ConfigurePage")
    }
}
