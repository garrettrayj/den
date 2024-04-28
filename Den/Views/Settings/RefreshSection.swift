//
//  RefreshSection.swift
//  Den
//
//  Created by Garrett Johnson on 4/28/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshSection: View {
    @AppStorage("BackgroundRefresh") private var backgroundRefresh = true
    
    var body: some View {
        Section {
            Toggle(isOn: $backgroundRefresh) {
                Label {
                    Text("Refresh in Background")
                } icon: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        } header: {
            Text("Refresh", comment: "Settings section header.")
        }
    }
}
