//
//  CheckForUpdates.swift
//  Den
//
//  Created by Garrett Johnson on 8/5/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

#if os(macOS)
import SwiftUI

import Sparkle

struct CheckForUpdatesView: View {
    @ObservedObject private var updaterViewModel: UpdaterViewModel
    
    private let updater: SPUUpdater
    
    init(updater: SPUUpdater) {
        self.updater = updater
        
        // Create our view model for our CheckForUpdatesView
        self.updaterViewModel = UpdaterViewModel(updater: updater)
    }
    
    var body: some View {
        Button("Check for Updates…", action: updater.checkForUpdates)
            .disabled(!updaterViewModel.canCheckForUpdates)
    }
}
#endif
