//
//  ColumnHeaderButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 8/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ColumnHeaderButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    @State private var hovering: Bool = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            #if os(macOS)
            .background(.thickMaterial.opacity(isEnabled && hovering ? 1 : 0))
            .background(.tertiary.opacity(isEnabled && hovering ? 1 : 0))
            #else
            .background(
                Rectangle()
                    .fill(.regularMaterial.opacity(isEnabled && hovering ? 0.7 : 0))
                    .overlay(.quaternary.opacity(isEnabled && hovering ? 0.7 : 0))
            )
            #endif
            .onHover { hovered in
                hovering = hovered
            }
    }
}
