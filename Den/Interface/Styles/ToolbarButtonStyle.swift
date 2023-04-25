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
        configuration.label
            .fontWeight(.medium)
            #if targetEnvironment(macCatalyst)
            .foregroundColor(
                isEnabled && configuration.isPressed ? .primary : .secondary
            )
            .padding(.horizontal, 6)
            .frame(minHeight: 28, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .foregroundStyle(
                        .quaternary.opacity(
                            isEnabled ? configuration.isPressed ? 0.75 : hovering ? 0.5 : 0 : 0
                        )
                    )
            )
            #else
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ?
                        .accentColor.opacity(0.75)
                        :
                        .accentColor
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
