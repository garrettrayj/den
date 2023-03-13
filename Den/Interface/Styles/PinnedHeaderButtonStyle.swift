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
    @Environment(\.isEnabled) private var isEnabled: Bool
    @State private var hovering: Bool = false

    var leadingPadding: CGFloat = 28
    var trailingPadding: CGFloat = 28

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(isEnabled ? Color(.label) : Color(.secondaryLabel))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
            .background(.thickMaterial)
            .background(
                Color(.systemGray3)
                    .colorInvert()
                    .opacity(isEnabled && hovering ? 0.25 : 0.15)
            )
            .onHover { hovered in
                hovering = hovered
            }
            .onDisappear {
                hovering = false
            }
    }
}
