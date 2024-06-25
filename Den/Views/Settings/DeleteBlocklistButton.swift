//
//  DeleteBlocklistButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteBlocklistButton: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var blocklist: Blocklist
    
    var body: some View {
        Button(role: .destructive) {
            Task {
                await BlocklistManager.removeContentRulesList(
                    identifier: blocklist.id?.uuidString
                )
                modelContext.delete(blocklist)
            }
        } label: {
            DeleteLabel()
        }
    }
}
