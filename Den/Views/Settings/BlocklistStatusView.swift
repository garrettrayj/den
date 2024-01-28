//
//  BlocklistStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/29/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BlocklistStatusView: View {
    @ObservedObject var blocklistStatus: BlocklistStatus
    
    var body: some View {
        Section {
            LabeledContent {
                VStack(alignment: .trailing) {
                    if let refreshed = blocklistStatus.refreshed {
                        Text(verbatim: "\(refreshed.formatted())")
                    }
                    if !blocklistStatus.compiledSuccessfully {
                        Text("Unable to Load Rules", comment: "Blocklist status message.")
                            .foregroundStyle(.red)
                    }
                }
            } label: {
                Text("Refreshed", comment: "Blocklist status label.")
            }
        } header: {
            Text("Status", comment: "Blocklist settings section header.")
        }
    }
}
