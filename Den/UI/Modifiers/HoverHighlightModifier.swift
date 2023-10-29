//
//  HoverHighlightModifier.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct HoverHighlightModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled

    @State private var isHovered: Bool = false

    func body(content: Content) -> some View {
        content
            .onHover { isHovered = $0 }
            .background {
                #if os(macOS)
                if isEnabled && isHovered && controlActiveState != .inactive {
                    Rectangle().fill(.fill.quaternary)
                }
                #else
                if isEnabled && isHovered {
                    Rectangle().fill(.fill.quaternary)
                }
                #endif
            }
    }
}
