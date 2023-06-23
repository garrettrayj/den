//
//  MainBoardModifier.swift
//  Den
//
//  Created by Garrett Johnson on 6/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct MainBoardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .padding()
            #else
            .padding([.horizontal, .bottom])
            #endif
    }
}
