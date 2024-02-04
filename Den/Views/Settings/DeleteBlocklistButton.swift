//
//  DeleteBlocklistButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct DeleteBlocklistButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var blocklist: Blocklist
    
    var body: some View {
        Button(role: .destructive) {
            Task {
                await BlocklistManager.removeContentRulesList(
                    identifier: blocklist.id?.uuidString
                )
                viewContext.delete(blocklist)
                
                do {
                    try viewContext.save()
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        } label: {
            DeleteLabel()
        }
    }
}
