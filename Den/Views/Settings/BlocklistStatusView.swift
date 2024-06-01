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
                        Text(refreshed.formatted())
                    }
                }
            } label: {
                Text("Updated", comment: "Blocklist status row label.")
            }
            
            LabeledContent {
                if blocklistStatus.httpCode == 0 {
                    Text("Unavailable", comment: "Blocklist response code placeholder.")
                } else {
                    Text(verbatim: "\(blocklistStatus.httpCode)")
                }
            } label: {
                Text("Response Code", comment: "Blocklist status row label.")
            }
            
            LabeledContent {
                if blocklistStatus.compiledSuccessfully {
                    Text("Yes", comment: "Blocklist compile/load status message.")
                } else {
                    Text("No", comment: "Blocklist compile/load status message.")
                        .foregroundStyle(.orange)
                }
            } label: {
                Text("Rules Applied", comment: "Blocklist status row label.")
            }
        } header: {
            Text("Status", comment: "Blocklist status section header.")
        }
    }
}
