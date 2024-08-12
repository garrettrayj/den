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
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        
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
                .background(.background)
                .overlay {
                    clipShape.strokeBorder(.separator)
                }
                .clipShape(clipShape)
        }
        #else
        content(configuration: configuration)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(clipShape)
        #endif
        
    }
    
    private var clipShape: some InsettableShape {
        RoundedRectangle(cornerRadius: 8)
    }
    
    private func content(configuration: Self.Configuration) -> some View {
        configuration.label.modifier(HoverHighlightModifier())
    }
}
