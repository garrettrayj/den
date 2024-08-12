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
    @Environment(\.colorScheme) private var colorScheme
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlStateActive
    #endif
    @Environment(\.isEnabled) private var isEnabled

    @Binding var read: Bool

    var roundedBottom: Bool = false
    var roundedTop: Bool = false
    var showDivider: Bool = false

    func makeBody(configuration: Self.Configuration) -> some View {
        #if os(macOS)
        if colorScheme == .dark {
            content(configuration: configuration)
                .background(.fill.quinary)
                .overlay {
                    clipShape.strokeBorder(.separator).padding(.top, roundedTop ? 0 : -1)
                }
                .clipShape(clipShape)
        } else {
            content(configuration: configuration)
                .background(.background)
                .overlay {
                    clipShape.strokeBorder(.separator).padding(.top, roundedTop ? 0 : -1)
                }
                .clipShape(clipShape)
        }
        #else
        content(configuration: configuration)
            .padding(.bottom, showDivider ? 1 : 0)
            .overlay(alignment: .bottom) { if showDivider { Divider() } }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(clipShape)
        #endif
    }
    
    private var clipShape: some InsettableShape {
        UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: roundedTop ? 8 : 0,
                bottomLeading: roundedBottom ? 8 : 0,
                bottomTrailing: roundedBottom ? 8 : 0,
                topTrailing: roundedTop ? 8 : 0
            )
        )
    }
    
    private var foregroundStyle: some ShapeStyle {
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
    
    private func content(configuration: Self.Configuration) -> some View {
        configuration.label.foregroundStyle(foregroundStyle).modifier(HoverHighlightModifier())
    }
}
