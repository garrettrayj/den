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

    @Binding var read: Bool

    var roundedBottom: Bool = false
    var roundedTop: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label
                .foregroundStyle(
                    isEnabled ?
                        read ? .secondary : .primary
                        :
                        .tertiary
                )
                .modifier(HoverHighlightModifier())
        }
        .background(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: roundedTop ? 8 : 0,
                    bottomLeading: roundedBottom ? 8 : 0,
                    bottomTrailing: roundedBottom ? 8 : 0,
                    topTrailing: roundedTop ? 8 : 0
                )
            )
            #if os(macOS)
            .fill(.background.quinary)
            #else
            .background(Color(.secondarySystemGroupedBackground))
            #endif
            .strokeBorder(.separator)
            .padding(.top, roundedTop ? 0 : -1)
        )
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: roundedTop ? 8 : 0,
                    bottomLeading: roundedBottom ? 8 : 0,
                    bottomTrailing: roundedBottom ? 8 : 0,
                    topTrailing: roundedTop ? 8 : 0
                )
            )
        )
    }
}
