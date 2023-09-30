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
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        ZStack {
            configuration.label
                .font(.title3)
                .foregroundStyle(isEnabled ? .primary : .secondary)
                .padding(.horizontal)
                .padding(.vertical, 12)
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
                    topLeading: 8,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 8
                )
            )
        )
    }
}
