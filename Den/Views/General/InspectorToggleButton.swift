//
//  InspectorToggleButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct InspectorToggleButton: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @Binding var showingInspector: Bool

    var body: some View {
        Button {
            showingInspector.toggle()
        } label: {
            Label {
                Text("Toggle Inspector", comment: "Button label.")
            } icon: {
                #if os(macOS)
                Image(systemName: "sidebar.trailing")
                #else
                if horizontalSizeClass == .compact {
                    Image(systemName: "rectangle.portrait.bottomhalf.inset.filled")
                } else {
                    Image(systemName: "sidebar.trailing")
                }
                #endif
            }
        }
        .accessibilityIdentifier("ToggleInspector")
    }
}
