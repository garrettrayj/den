//
//  GroupedBackground.swift
//  Den
//
//  Created by Garrett Johnson on 4/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GroupedBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if colorScheme == .dark {
            Rectangle()
                #if targetEnvironment(macCatalyst)
                .fill(.thinMaterial)
                #else
                .fill(.background)
                #endif
                .edgesIgnoringSafeArea(.all)
        } else {
            Rectangle()
                #if targetEnvironment(macCatalyst)
                .fill(.regularMaterial)
                #else
                .fill(.regularMaterial)
                .background(.quaternary)
                #endif
                .edgesIgnoringSafeArea(.all)
        }
    }
}
