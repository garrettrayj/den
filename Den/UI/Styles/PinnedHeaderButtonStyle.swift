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
    @Environment(\.isEnabled) private var isEnabled

    @State private var isHovered: Bool = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .padding(.vertical, 12)
            #if os(macOS)
            .background(
                Rectangle()
                    .fill(.thickMaterial)
                    .background(.secondary.opacity(isEnabled && isHovered ? 0.75 : 0.5))
            )
            #else
            .background(
                Rectangle()
                    .fill(isEnabled && isHovered ? .thickMaterial : .regularMaterial)
                    .overlay(isEnabled && isHovered ? .quaternary : .quinary)
            )
            #endif
            .onHover { hovering in
                isHovered = hovering
            }
    }
}
