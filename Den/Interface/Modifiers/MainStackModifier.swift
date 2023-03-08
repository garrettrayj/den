//
//  MainStackModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct MainStackModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.bottom)
    }
}
