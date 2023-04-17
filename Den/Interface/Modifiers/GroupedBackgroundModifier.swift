//
//  GroupedBackgroundModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GroupedBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .background(.thinMaterial)
            .background(.background)
            #else
            .background(.regularMaterial.opacity(colorScheme == .dark ? 0 : 1))
            .background(.background)
            #endif
    }
}
