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

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                isEnabled ?
                    read ? .secondary : .primary
                    :
                    .tertiary
            )
            .modifier(HoverHighlightModifier())
    }
}
