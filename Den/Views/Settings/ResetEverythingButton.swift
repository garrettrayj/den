//
//  ResetEverythingButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import SDWebImage

struct ResetEverythingButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingResetAlert = false

    var body: some View {
        Button(role: .destructive) {
            showingResetAlert = true
        } label: {
            Label {
                Text("Reset Everything", comment: "Button label.")
            } icon: {
                Image(systemName: "arrow.counterclockwise").foregroundStyle(.red)
            }
        }
        .alert(
            Text("Reset Everything?", comment: "Alert title."),
            isPresented: $showingResetAlert,
            actions: {
                Button(role: .cancel) {
                    // pass
                } label: {
                    Text("Cancel", comment: "Button label.")
                }
                .accessibilityIdentifier("CancelReset")

                Button(role: .destructive) {
                    Task {
                        await resetEverything()
                    }
                } label: {
                    Text("Reset", comment: "Button label.")
                }
                .accessibilityIdentifier("ConfirmReset")
            },
            message: {
                Text(
                    "All content will be deleted. Default settings will be restored.",
                    comment: "Alert message."
                )
            }
        )
        .accessibilityIdentifier("ResetEverything")
    }

    private func emptyCache() async {
        SDImageCache.shared.clearMemory()
        await SDImageCache.shared.clearDiskOnCompletion()
        URLCache.shared.removeAllCachedResponses()
    }

    private func resetEverything() async {
        await emptyCache()
        
        await MainActor.run {
            // Entities that must be cleared with verbose truncate function so UI will update.
            let verboseTruncateList = [
                Blocklist.self,
                Item.self,
                Page.self,
                Tag.self,
                Trend.self
            ]
            
            verboseTruncateList.forEach {
                PersistenceController.shared.verboseTruncate($0, context: viewContext)
            }
            
            // Entities that may be cleared using the more performant batch truncate function.
            let batchTruncateList = [
                BlocklistStatus.self,
                FeedData.self,
                History.self
            ]
            
            batchTruncateList.forEach {
                PersistenceController.shared.batchTruncate($0, context: viewContext)
            }

            do {
                try viewContext.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
        
        await BlocklistManager.cleanupContentRulesLists()

        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
}
