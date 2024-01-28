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

    @Binding var selection: Blocklist?
    
    var body: some View {
        Button(role: .destructive) {
            guard let blocklist = selection else { return }
            
            Task {
                await BlocklistManager.removeContentRulesList(
                    identifier: blocklist.id?.uuidString
                )
                viewContext.delete(blocklist)
                
                do {
                    try viewContext.save()
                    selection = nil
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        } label: {
            #if os(macOS)
            DeleteLabel(symbol: "minus")
            #else
            DeleteLabel()
            #endif
        }
    }
}
