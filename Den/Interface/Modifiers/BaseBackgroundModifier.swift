//
//  BaseBackgroundModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BaseBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(.background)
            .scrollContentBackground(.hidden)
    }
}
