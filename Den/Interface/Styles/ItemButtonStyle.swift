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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let read: Bool

    @State private var hovering: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                isEnabled ?
                    read ? .secondary : .primary
                    :
                    .tertiary
            )
            .frame(maxWidth: .infinity)
            .background(SecondaryGroupedBackground(highlight: isEnabled && hovering))
            .onHover { hovered in
                hovering = hovered
            }
    }
}
