//
//  ToggleBlocklistsButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ToggleBlocklistsButton: View {
    @Bindable var browserViewModel: BrowserViewModel

    var body: some View {
        Button {
            Task {
                await browserViewModel.toggleBlocklists()
            }
        } label: {
            if browserViewModel.useBlocklists {
                Label {
                    Text("Turn Off Blocklists", comment: "Button label.")
                } icon: {
                    Image(systemName: "shield.slash")
                }
            } else {
                Label {
                    Text("Turn On Blocklists", comment: "Button label.")
                } icon: {
                    Image(systemName: "checkmark.shield")
                }
            }
        }
    }
}
