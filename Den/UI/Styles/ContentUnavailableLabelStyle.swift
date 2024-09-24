//
//  ContentUnavailableLabelStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ContentUnavailableLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 16) {
            configuration.icon.foregroundStyle(.tertiary)
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
