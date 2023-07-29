//
//  HoverShadowButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct HoverShadowButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    @State private var hovering: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                .quaternary.opacity(
                    isEnabled && hovering ?
                    colorScheme == .dark ? 1 : 0.5
                    : 0
                )
            )
            .onHover { hovered in
                hovering = hovered
            }
    }
}
