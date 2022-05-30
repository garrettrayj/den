//
//  SettingsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 1/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

import SDWebImageSwiftUI

final class SettingsViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager
    let profileManager: ProfileManager
    let refreshManager: RefreshManager
    let cacheManager: CacheManager
    let themeManager: ThemeManager

    var hideReadItems: Binding<Bool> {
        Binding<Bool>(
            get: {
                return self.profileManager.activeProfile?.hideReadItems ?? false
            },
            set: { isOn in
                self.profileManager.activeProfile?.hideReadItems = isOn
            }
        )
    }

    init(
        viewContext: NSManagedObjectContext,
        crashManager: CrashManager,
        profileManager: ProfileManager,
        refreshManager: RefreshManager,
        cacheManager: CacheManager,
        themeManager: ThemeManager
    ) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profileManager = profileManager
        self.refreshManager = refreshManager
        self.cacheManager = cacheManager
        self.themeManager = themeManager
    }

    func saveProfile() {
        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    func applyStyle() {
        themeManager.applyStyle()
    }

    func clearCache() {
        guard let profile = profileManager.activeProfile else { return }
        refreshManager.cancel()
        cacheManager.resetFeeds()

        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()

        NotificationCenter.default.post(name: .profileRefreshed, object: profile.objectID)
    }

    func clearHistory() {
        guard let profile = profileManager.activeProfile else { return }
        profile.historyArray.forEach { history in
            self.viewContext.delete(history)
        }

        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }

        profile.pagesArray.forEach({ page in
            page.feedsArray.forEach { feed in
                feed.objectWillChange.send()
            }
        })
    }

    func restoreUserDefaults() {
        // Clear our UserDefaults domain
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()

        themeManager.objectWillChange.send()
    }

    func resetEverything() {
        refreshManager.cancel()
        restoreUserDefaults()
        profileManager.resetProfiles()
    }

    func openHomepage() {
        if let url = URL(string: "https://garrettjohnson.com/apps/") {
            UIApplication.shared.open(url)
        }
    }

    func openCommunity() {
        if let url = URL(string: "https://discord.gg/NS9hMrYrnt") {
            UIApplication.shared.open(url)
        }
    }

    func emailSupport() {
        // Note: "mailto:" links do not work in simulator, only on devices
        if let url = URL(string: "mailto:support@devsci.net") {
            UIApplication.shared.open(url)
        }
    }

    func openPrivacyPolicy() {
        if let url = URL(string: "https://garrettjohnson.com/privacy/") {
            UIApplication.shared.open(url)
        }
    }
}
