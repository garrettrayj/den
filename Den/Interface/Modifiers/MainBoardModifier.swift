//
//  MainBoardModifier.swift
//  Den
//
//  Created by Garrett Johnson on 2/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct MainBoardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            #if targetEnvironment(macCatalyst)
            .padding(.top)
            #else
            .padding(.top, 0)
            #endif
            .padding(.bottom, 16 + 12)
    }
}
