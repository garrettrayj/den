//
//  InspectorToggleButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
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
                Text("Toggle Inspector", comment: "Button label.")
            } icon: {
                Image(systemName: symbol)
            }
        }
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
