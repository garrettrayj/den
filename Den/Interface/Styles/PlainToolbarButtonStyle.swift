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
            #if targetEnvironment(macCatalyst)
            .fontWeight(.semibold)
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ?
                        Color(.secondaryLabel).opacity(0.5)
                        :
                        hovering ?
                            Color(.secondaryLabel).opacity(0.75)
                            :
                            Color(.secondaryLabel)
                    :
                    Color(.tertiaryLabel)
            )
            #else
            .foregroundColor(
                isEnabled ?
                    configuration.isPressed ?
                        Color(.tintColor).opacity(0.5)
                        :
                        Color(.tintColor)
                    :
                    Color(.tertiaryLabel)
            )
            .background(Color.clear)
            #endif
            .onHover { hovered in
                hovering = hovered
            }
            .contentShape(Rectangle())
    }
}
