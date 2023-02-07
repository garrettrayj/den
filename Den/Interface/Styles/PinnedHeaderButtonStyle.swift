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

    var horizontalPadding: CGFloat = 24

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundColor(
                isEnabled ? .primary : .secondary
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: UIConstants.sectionHeaderHeight)
            .padding(.horizontal, horizontalPadding)
            .background(
                isEnabled ?
                    hovering ? Color(UIColor.quaternarySystemFill) : .clear
                : .clear
            )
            .onHover { hovered in
                hovering = hovered
            }
            .onDisappear {
                hovering = false
            }
    }
}
