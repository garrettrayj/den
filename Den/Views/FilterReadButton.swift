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
            Label {
                Text("Filter Read", comment: "Button label")
            } icon: {
                Image(
                    systemName: hideRead ?
                      "line.3.horizontal.decrease.circle.fill"
                      : "line.3.horizontal.decrease.circle"
                )
            }
        }
        .buttonStyle(PlainToolbarButtonStyle())
        .accessibilityIdentifier("filter-read-button")
    }
}
