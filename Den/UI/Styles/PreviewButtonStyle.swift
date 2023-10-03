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

struct PreviewButtonStyle: ButtonStyle {
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
        #if os(macOS)
        .background(.background)
        #else
        .background(Color(.secondarySystemGroupedBackground))
        #endif
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
