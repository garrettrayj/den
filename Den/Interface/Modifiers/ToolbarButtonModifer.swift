//
//  ToolbarButtonModifer.swift
//  Den
//
//  Created by Garrett Johnson on 4/10/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ToolbarButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .buttonStyle(.plain)
            #else
            .buttonStyle(.borderless)
            #endif
    }
}
