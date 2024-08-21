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
    @Environment(\.isEnabled) private var isEnabled

    @State private var isHovered: Bool = false

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                withAnimation(.linear(duration: 0.05)) {
                    isHovered = hovering
                }
            }
            .background {
                if isEnabled && isHovered {
                    Rectangle().fill(.selection.quinary)
                }
            }
    }
}
