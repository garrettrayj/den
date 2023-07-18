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
                Text("Filter", comment: "Button label.")
            } icon: {
                Image(
                    systemName: hideRead ?
                      "line.3.horizontal.decrease.circle.fill"
                      : "line.3.horizontal.decrease.circle"
                )
            }
        }
        .accessibilityIdentifier("FilterRead")
    }
}
