//
//  CompactContentUnavailableLabelStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CompactContentUnavailableLabelStyle: LabelStyle {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlStateActive
    #endif
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 8) {
            configuration.icon
                .foregroundStyle(iconForegroundStyle)
            configuration.title
                .foregroundStyle(titleForegroundStyle)
        }
        .imageScale(.large)
        .font(.callout)
    }
    
    private var iconForegroundStyle: HierarchicalShapeStyle {
        #if os(macOS)
        if controlStateActive == .inactive || !isEnabled {
            return .quaternary
        } else {
            return .tertiary
        }
        #else
        return .secondary
        #endif
    }
    
    private var titleForegroundStyle: HierarchicalShapeStyle {
        #if os(macOS)
        if controlStateActive == .inactive || !isEnabled {
            return .tertiary
        } else {
            return .secondary
        }
        #else
        return .secondary
        #endif
    }
}
