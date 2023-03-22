//
//  ItemLinkButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let read: Bool

    @State private var hovering: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(
                isEnabled ?
                    read ? Color(.secondaryLabel) : Color(.label)
                :
                    read ? Color(.quaternaryLabel) : Color(.tertiaryLabel)
            )
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial.opacity(isEnabled && hovering ? 0.65 : 0))
            .onHover { hovered in
                hovering = hovered
            }
            .onDisappear {
                hovering = false
            }
    }
}
