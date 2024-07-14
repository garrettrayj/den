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

    var body: some View {
        Button {
            hideRead.toggle()
        } label: {
            Label {
                Text("Filter Read", comment: "Button label.")
            } icon: {
                Image(systemName: "line.3.horizontal.decrease")
                    .symbolVariant(hideRead ? .circle.fill : .circle)
            }
        }
        .help(
            hideRead ? Text("Show read items", comment: "Button help text.") :
                Text("Hide read items", comment: "Button help text.")
        )
        .accessibilityIdentifier("FilterRead")
    }
}
