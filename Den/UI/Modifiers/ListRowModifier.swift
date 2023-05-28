//
//  ListRowModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .listRowBackground(SecondaryGroupedBackground())
            #endif
    }
}
