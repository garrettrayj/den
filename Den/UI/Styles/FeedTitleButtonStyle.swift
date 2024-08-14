//
//  FeedTitleButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedTitleButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        #if os(macOS)
        if colorScheme == .dark {
            content(configuration: configuration)
                .background(.fill.quinary)
                .overlay {
                    clipShape.strokeBorder(.separator)
                }
                .clipShape(clipShape)
                .background(.background)
                .background(.windowBackground)
        } else {
            content(configuration: configuration)
                .padding(.bottom, 1)
                .overlay(Divider(), alignment: .bottom)
                .background(.background)
                .clipShape(clipShape)
                .background(.windowBackground)
        }
        #else
        content(configuration: configuration)
            .padding(.bottom, 1)
            .overlay(Divider(), alignment: .bottom)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(clipShape)
            .background(Color(.systemGroupedBackground))
        #endif
    }
    
    private func content(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundStyle(foregroundStyle)
            .padding(12)
            .modifier(HoverHighlightModifier())
    }
    
    private var clipShape: some InsettableShape {
        UnevenRoundedRectangle(
            cornerRadii: .init(topLeading: 8, bottomLeading: 0, bottomTrailing: 0, topTrailing: 8)
        )
    }
    
    private var foregroundStyle: some ShapeStyle {
        #if os(macOS)
        if controlActiveState == .inactive || !isEnabled {
            return .tertiary
        } else {
            return .primary
        }
        #else
        if !isEnabled {
            return .tertiary
        } else {
            return .primary
        }
        #endif
    }
}
