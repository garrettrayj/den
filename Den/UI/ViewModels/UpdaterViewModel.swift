//
//  UpdaterViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/5/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

#if canImport(Sparkle)
import Foundation

import Sparkle

/// Publishes when new updates can be checked by the user
final class UpdaterViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates).assign(to: &$canCheckForUpdates)
    }
}
#endif
