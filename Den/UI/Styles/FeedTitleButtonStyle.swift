//
//  FeedTitleButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct FeedTitleButtonStyle: ButtonStyle {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled
    
    var foregroundStyle: some ShapeStyle {
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

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ZStack {
            configuration.label
                .font(.title3)
                .foregroundStyle(foregroundStyle)
                .padding(12)
                .modifier(HoverHighlightModifier())
                .padding(.bottom, 1)
                .overlay(Divider(), alignment: .bottom)
        }
        #if os(macOS)
        .background(.background)
        #else
        .background(Color(.secondarySystemGroupedBackground))
        #endif
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 8,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 8
                )
            )
        )
    }
}
