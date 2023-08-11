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

    @State private var hovering: Bool = false

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundStyle(isEnabled ? .primary : .secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            #if os(macOS)
            .background(
                Rectangle()
                    .fill(.thickMaterial)
                    .background(.tertiary.opacity(isEnabled && hovering ? 1 : 0.75))
                    .ignoresSafeArea(.all)
            )
            #else
            .background(
                Rectangle()
                    .fill(isEnabled && hovering ? .thickMaterial : .regularMaterial)
                    .overlay(isEnabled && hovering ? .quaternary : .quinary)
                    .ignoresSafeArea(.all)
            )
            #endif
            .onHover { hovered in
                hovering = hovered
            }
    }
}
