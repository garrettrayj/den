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
            .background(.thinMaterial.opacity(colorScheme == .light ? 1 : 0))
            .background(.background)
            #else
            .background(Color(.systemGroupedBackground))
            #endif
    }
}
