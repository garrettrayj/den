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
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        #if os(macOS)
        if colorScheme == .dark {
            content(configuration: configuration)
                .background(.fill.quaternary)
                .overlay {
                    clipShape.strokeBorder(.separator)
                }
                .clipShape(clipShape)
                .background(.background)
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
            .foregroundStyle(isEnabled ? .primary : .tertiary)
            .padding(12)
    }
    
    private var clipShape: some InsettableShape {
        UnevenRoundedRectangle(
            cornerRadii: .init(topLeading: 8, bottomLeading: 0, bottomTrailing: 0, topTrailing: 8)
        )
    }
}
