//
//  ContentUnavailableLabelStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ContentUnavailableLabelStyle: LabelStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 16) {
            configuration.icon.foregroundStyle(.secondary)
            configuration.title.foregroundStyle(.secondary)
        }
        .imageScale(.large)
        #if os(macOS)
        .font(.largeTitle.weight(.bold))
        #else
        .font(.title.weight(.bold))
        #endif
    }
}
