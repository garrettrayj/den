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

    var body: some View {
        #if targetEnvironment(macCatalyst)
        if colorScheme == .dark {
            Rectangle().fill(.ultraThickMaterial).background(.secondary)
        } else {
            Rectangle().fill(.ultraThickMaterial).background(.tertiary)
        }
        #else
        if colorScheme == .dark {
            Rectangle().fill(.regularMaterial).background(.quaternary)
        } else {
            Rectangle().fill(.regularMaterial).background(.secondary)
        }
        #endif
    }
}
