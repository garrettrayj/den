//
//  PinnedSectionHeaderModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/21/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PinnedSectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            #if targetEnvironment(macCatalyst)
            .background(.thickMaterial)
            #else
            .background(.regularMaterial)
            #endif
            .background(.tertiary.opacity(0.5))
    }
}
