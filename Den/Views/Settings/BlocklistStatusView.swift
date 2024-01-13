//
//  BlocklistStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/29/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BlocklistStatusView: View {
    @ObservedObject var blocklistStatus: BlocklistStatus
    
    var body: some View {
        Section {
            LabeledContent {
                if let refreshed = blocklistStatus.refreshed {
                    Text(verbatim: "\(refreshed.formatted())")
                } else {
                    Text("Unknown", comment: "Blocklist refresh date not available placeholder.")
                }
            } label: {
                Text("Refreshed", comment: "Blocklist status row label.")
            }
            LabeledContent {
                Text(verbatim: "\(blocklistStatus.totalConvertedCount)")
            } label: {
                Text("Converted Rules", comment: "Blocklist status row label.")
            }
            LabeledContent {
                Text(verbatim: "\(blocklistStatus.errorsCount)")
            } label: {
                Text("Errors", comment: "Blocklist status row label.")
            }
        } header: {
            Text("Status", comment: "Blocklist settings section header.")
        }
    }
}
