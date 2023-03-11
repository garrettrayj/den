//
//  ToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 9/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    @State private var hovering: Bool = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        #if targetEnvironment(macCatalyst)
        configuration.label
            .frame(height: 28, alignment: .center)
            .padding(.horizontal, 6)
            .fontWeight(.semibold)
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ? Color.primary : Color.secondary
                    :
                    Color(.tertiaryLabel)
            )
            .background(
                isEnabled ?
                    configuration.isPressed ?
                        Color(.systemFill)
                        :
                        hovering ?
                            Color(.quaternarySystemFill)
                            :
                            Color.clear
                    :
                    Color.clear
            )
            .cornerRadius(6)
            .onHover { hovered in
                hovering = hovered
            }
        #else
        configuration.label
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ?
                        Color.accentColor.opacity(0.5)
                        :
                        Color.accentColor
                    :
                    Color(.tertiaryLabel)
            )
            .background(Color.clear)
            .contentShape(Rectangle())
            .onHover { hovered in
                hovering = hovered
            }
        #endif

    }
}
