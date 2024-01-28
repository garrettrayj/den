//
//  BasicHoverButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 8/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct BasicHoverButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack {
            configuration.label.modifier(HoverHighlightModifier())
        }
        #if os(macOS)
        .background(.background)
        #else
        .background(Color(.secondarySystemGroupedBackground))
        #endif
        .clipShape(
            RoundedRectangle(cornerRadius: 8)
        )
    }
}
