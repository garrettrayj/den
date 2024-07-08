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

    @SceneStorage("ShowingInspector") private var showingInspector = false
    
    init(initialValue: Bool, storageKey: String) {
        _showingInspector = .init(wrappedValue: false, storageKey)
    }

    var body: some View {
        Button {
            showingInspector.toggle()
        } label: {
            Label {
                Text("Inspector", comment: "Button label.")
            } icon: {
                Image(systemName: symbol)
            }
        }
        .help(
            showingInspector ? Text("Hide inspector", comment: "Button help text.") :
                Text("Show inspector", comment: "Button help text.")
        )
        .accessibilityIdentifier("ToggleInspector")
    }
    
    private var symbol: String {
        if horizontalSizeClass == .compact {
            "rectangle.portrait.bottomhalf.inset.filled"
        } else {
            "sidebar.trailing"
        }
    }
}
