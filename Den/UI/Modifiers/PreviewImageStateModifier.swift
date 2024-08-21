//
//  PreviewImageStateModifier.swift
//  Den
//
//  Created by Garrett Johnson on 10/28/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewImageStateModifier: ViewModifier {
    @Environment(\.isEnabled) private var isEnabled
    
    let isRead: Bool
    
    func body(content: Content) -> some View {
        content
            .grayscale(grayscale)
            .overlay(overlay)
    }
    
    private var grayscale: CGFloat {
        if !isEnabled {
            return 0.4
        } else if isRead {
            return 0.2
        } else {
            return 0
        }
    }
    
    private var overlay: some ShapeStyle {
        if !isEnabled {
            return .background.opacity(0.6)
        } else if isRead {
            return .background.opacity(0.4)
        } else {
            return .background.opacity(0)
        }
    }
}
