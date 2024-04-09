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
    @State private var showingResetAlert = false

    var body: some View {
        Button(role: .destructive) {
            showingResetAlert = true
        } label: {
            Label {
                Text("Reset Everything", comment: "Button label.").lineLimit(1)
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
                    "All pages/feeds will be removed. Default settings will be restored.",
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

        let container = PersistenceController.shared.container
        await container.performBackgroundTask { context in
            guard
                let blocklists = try? context.fetch(Blocklist.fetchRequest()) as [Blocklist],
                let pages = try? context.fetch(Page.fetchRequest()) as [Page],
                let tags = try? context.fetch(Tag.fetchRequest()) as [Tag],
                let trends = try? context.fetch(Trend.fetchRequest()) as [Trend]
            else {
                return
            }

            for page in pages {
                page.feedsArray.compactMap({ $0.feedData }).forEach { context.delete($0) }
                context.delete(page)
            }
            
            trends.forEach { context.delete($0) }
            tags.forEach { context.delete($0) }
            
            for blocklist in blocklists {
                if let status = blocklist.blocklistStatus {
                    context.delete(status)
                }
                context.delete(blocklist)
            }

            do {
                try context.save()
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
