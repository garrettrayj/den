//
//  ContentUnavailableLabelStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ContentUnavailableLabelStyle: LabelStyle {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlStateActive
    #endif
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 12) {
            configuration.icon
                .font(.system(size: 36))
                .foregroundStyle(iconForegroundStyle)
            configuration.title
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(titleForegroundStyle)
        }
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
