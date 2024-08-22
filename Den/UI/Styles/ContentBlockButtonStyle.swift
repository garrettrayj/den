//
//  ContentBlockButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 8/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ContentBlockButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        #if os(macOS)
        if colorScheme == .dark {
            configuration.label
                .background(.fill.quinary)
                .overlay {
                    clipShape.strokeBorder(.separator)
                }
                .clipShape(clipShape)
                .background(.background)
                .background(.windowBackground)
        } else {
            configuration.label
                .background(.background)
                .clipShape(clipShape)
        }
        #else
        configuration.label
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(clipShape)
        #endif
        
    }
    
    private var clipShape: some InsettableShape {
        RoundedRectangle(cornerRadius: 8)
    }
}
