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
    @Environment(\.isEnabled) private var isEnabled

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
            .background(
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .background(.quaternary)
                    .ignoresSafeArea(.all)
                    .opacity(isEnabled && hovering ? 1 : 0)
            )
            .onHover { hovered in
                hovering = hovered
            }
    }
}
