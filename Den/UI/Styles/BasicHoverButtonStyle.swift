//
//  BasicHoverButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 8/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BasicHoverButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label.modifier(HoverHighlightModifier())
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                #if os(macOS)
                .fill(.background.quinary)
                #else
                .fill(Color(.secondarySystemGroupedBackground))
                #endif
                .strokeBorder(.separator)
        )
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
    }
}
