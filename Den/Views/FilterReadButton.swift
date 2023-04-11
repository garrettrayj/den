//
//  FilterReadButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FilterReadButton: View {
    @Binding var hideRead: Bool

    let callback: () -> Void

    var body: some View {
        Button {
            hideRead.toggle()
            callback()
        } label: {
            Label(
                "Filter Read",
                systemImage: hideRead ?
                    "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle"
            )
        }
        .modifier(ToolbarButtonModifier())
        .accessibilityIdentifier("filter-read-button")
    }
}
