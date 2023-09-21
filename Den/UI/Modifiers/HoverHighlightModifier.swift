//
//  HoverHighlightModifier.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct HoverHighlightModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled

    @State private var isHovered: Bool = false

    func body(content: Content) -> some View {
        content
            .onHover { isHovered = $0 }
            .background {
                if isEnabled && isHovered {
                    if colorScheme == .dark {
                        Rectangle().fill(.fill.tertiary)
                    } else {
                        Rectangle().fill(.thinMaterial)
                    }
                }
            }
    }
}
