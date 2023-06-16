//
//  WelcomeToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct WelcomeToolbar: ToolbarContent {
    @ObservedObject var profile: Profile

    var body: some ToolbarContent {
        #if os(macOS)
        ToolbarItem {
            CommonStatus(profile: profile)
        }
        #else
        ToolbarItem(placement: .bottomBar) { Spacer() }
        ToolbarItem(placement: .bottomBar) {
            CommonStatus(profile: profile)
        }
        ToolbarItem(placement: .bottomBar) { Spacer() }
        #endif
    }
}
