//
//  RoundedContainerModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RoundedContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .topLeading)
            #if targetEnvironment(macCatalyst)
            .cornerRadius(8)
            #else
            .cornerRadius(10)
            #endif
    }
}
