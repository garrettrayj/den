//
//  PreviewImageStateModifier.swift
//  Den
//
//  Created by Garrett Johnson on 10/28/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PreviewImageStateModifier: ViewModifier {
    let isRead: Bool
    
    func body(content: Content) -> some View {
        content
            .grayscale(grayscale)
            .overlay(overlay)
    }
    
    private var grayscale: CGFloat {
        if isRead {
            return 0.2
        } else {
            return 0
        }
    }
    
    private var overlay: some ShapeStyle {
        if isRead {
            return .background.opacity(0.4)
        } else {
            return .background.opacity(0)
        }
    }
}
