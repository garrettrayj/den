//
//  InspectorToggleButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct InspectorToggleButton: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @Binding var showingInspector: Bool

    var body: some View {
        Button {
            showingInspector.toggle()
        } label: {
            Label {
                if showingInspector {
                    Text("Hide Inspector", comment: "Button label.")
                } else {
                    Text("Show Inspector", comment: "Button label.")
                }
            } icon: {
                if horizontalSizeClass == .compact {
                    Image(systemName: "rectangle.portrait.bottomhalf.inset.filled")
                } else {
                    Image(systemName: "sidebar.trailing")
                }
            }
        }
        .help(
            showingInspector ? Text("Hide Inspector", comment: "Button help text.") :
                Text("Show Inspector", comment: "Button help text.")
        )
        .accessibilityIdentifier("ToggleInspector")
    }
}
