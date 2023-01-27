//
//  UntappableModifier.swift
//  Den
//
//  Created by Garrett Johnson on 1/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct UntappableModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .onTapGesture {
                return
            }
            .onTapGesture(count: 2) {
                return
            }
    }
}
