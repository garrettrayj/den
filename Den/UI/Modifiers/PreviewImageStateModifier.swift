//
//  PreviewImageStateModifier.swift
//  Den
//
//  Created by Garrett Johnson on 10/28/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct PreviewImageStateModifier: ViewModifier {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled
    
    let isRead: Bool
    
    private var grayscale: CGFloat {
        #if os(macOS)
        if controlActiveState == .inactive || !isEnabled {
            return 0.4
        } else if isRead {
            return 0.2
        } else {
            return 0
        }
        #else
        if !isEnabled {
            return 0.4
        } else if isRead {
            return 0.2
        } else {
            return 0
        }
        #endif
    }
    
    private var overlay: some ShapeStyle {
        #if os(macOS)
        if controlActiveState == .inactive || !isEnabled {
            return .background.opacity(0.6)
        } else if isRead {
            return .background.opacity(0.4)
        } else {
            return .background.opacity(0)
        }
        #else
        if !isEnabled {
            return .background.opacity(0.6)
        } else if isRead {
            return .background.opacity(0.4)
        } else {
            return .background.opacity(0)
        }
        #endif
    }

    func body(content: Content) -> some View {
        content
            .grayscale(grayscale)
            .overlay(overlay)
    }
}
