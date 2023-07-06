//
//  PinnedHeaderButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PinnedHeaderButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    @State private var hovering: Bool = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(isEnabled ? .primary : .secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .background(isEnabled && hovering ? .thickMaterial : .regularMaterial)
            .background(isEnabled && hovering ? .tertiary : .quaternary)
            .onHover { hovered in
                hovering = hovered
            }
    }
}
