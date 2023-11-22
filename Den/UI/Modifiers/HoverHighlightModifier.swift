//
//  HoverHighlightModifier.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct HoverHighlightModifier: ViewModifier {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled

    @State private var isHovered: Bool = false
    
    private var showingHighlight: Bool {
        #if os(macOS)
        isEnabled && isHovered && controlActiveState != .inactive
        #else
        isEnabled && isHovered
        #endif
    }

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                withAnimation(.linear(duration: 0.05)) {
                    isHovered = hovering
                }
            }
            .background {
                if showingHighlight {
                    Rectangle().fill(.selection.quinary)
                }
            }
    }
}
