//
//  ItemLinkButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct PreviewButtonStyle: ButtonStyle {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlStateActive
    #endif
    @Environment(\.isEnabled) private var isEnabled

    @Binding var read: Bool

    var roundedBottom: Bool = false
    var roundedTop: Bool = false
    var showDivider: Bool = false
    
    var foregroundStyle: some ShapeStyle {
        #if os(macOS)
        if controlStateActive == .inactive || !isEnabled {
            return .tertiary
        } else if read {
            return .secondary
        } else {
            return .primary
        }
        #else
        if !isEnabled {
            return .tertiary
        } else if read {
            return .secondary
        } else {
            return .primary
        }
        #endif
    }

    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            if showDivider {
                configuration.label
                    .foregroundStyle(foregroundStyle)
                    .modifier(HoverHighlightModifier())
                    .padding(.bottom, 1)
                    .overlay(alignment: .bottom) { Divider() }
            } else {
                configuration.label
                    .foregroundStyle(foregroundStyle)
                    .modifier(HoverHighlightModifier())
            }
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
