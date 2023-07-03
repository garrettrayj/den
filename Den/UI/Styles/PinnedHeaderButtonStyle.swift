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

    var leadingPadding: CGFloat = 28
    var trailingPadding: CGFloat = 28

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(isEnabled ? .primary : .secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.leading, leadingPadding)
            .padding(.trailing, trailingPadding)
            .background(TertiaryGroupedHighlight().opacity(isEnabled && hovering ? 1 : 0))
            .background(TertiaryGroupedBackground())
            .onHover { hovered in
                hovering = hovered
            }
    }
}
