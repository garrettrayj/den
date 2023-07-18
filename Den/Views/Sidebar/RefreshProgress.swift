//
//  RefreshProgress.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshProgress: View {
    @Environment(\.displayScale) private var displayScale
    
    @ObservedObject var profile: Profile
    
    let progress: Progress

    var body: some View {
        ProgressView(progress)
            .progressViewStyle(.circular)
            .labelsHidden()
            #if os(macOS)
            .scaleEffect(1 / displayScale)
            .frame(width: 34)
            #endif
    }
}
