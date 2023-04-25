//
//  PlainToolbarButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PlainToolbarButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool

    @State private var hovering: Bool = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .fontWeight(.medium)
            #if targetEnvironment(macCatalyst)
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ?
                        .secondary
                        :
                        hovering ? .primary : .secondary
                    :
                    .secondary
            )
            #else
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ?
                        .accentColor.opacity(0.5)
                        :
                        hovering ? .accentColor.opacity(0.75) : .accentColor
                    :
                    .secondary
            )
            #endif
            .background(.clear)
            .contentShape(Rectangle())
            .onHover { hovered in
                hovering = hovered
            }
    }
}
