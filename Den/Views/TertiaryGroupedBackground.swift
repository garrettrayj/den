//
//  TertiaryGroupedBackground.swift
//  Den
//
//  Created by Garrett Johnson on 4/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TertiaryGroupedBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var highlight = false

    var body: some View {
        #if targetEnvironment(macCatalyst)
        if highlight {
            Rectangle().fill(.thickMaterial).background(.secondary)
        } else {
            Rectangle().fill(.ultraThickMaterial).background(.secondary)
        }
        #else
        if colorScheme == .dark {
            if highlight {
                Rectangle().fill(.thickMaterial).background(.tertiary)
            } else {
                Rectangle().fill(.regularMaterial).background(.tertiary)
            }
        } else {
            if highlight {
                Rectangle().fill(.thickMaterial).background(.secondary)
            } else {
                Rectangle().fill(.regularMaterial).background(.secondary)
            }
        }
        #endif
    }
}
