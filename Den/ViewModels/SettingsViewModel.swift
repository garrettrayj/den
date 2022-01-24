//
//  SettingsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 1/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var showingResetAlert = false
    @Published var historyRentionDays: Int = 0

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    private var profileManager: ProfileManager
    private var refreshManager: RefreshManager
    private var cacheManager: CacheManager
    private var themeManager: ThemeManager

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

    func loadProfile() {
        guard let profile = profileManager.activeProfile else { return }
        historyRentionDays = profile.wrappedHistoryRetention
    }

    func saveProfile() {
        guard let profile = profileManager.activeProfile else { return }
        if historyRentionDays != profile.wrappedHistoryRetention {
            profile.wrappedHistoryRetention = historyRentionDays
        }

        if self.viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch let error as NSError {
                crashManager.handleCriticalError(error)
            }
        }
    }

    func clearCache() {
        guard let profile = profileManager.activeProfile else { return }
        refreshManager.cancel()
        cacheManager.resetFeeds()
        profile.pagesArray.forEach { page in
            NotificationCenter.default.post(name: .pageRefreshed, object: page.objectID)
        }
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
        if let url = URL(string: "https://devsci.net") {
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
        if let url = URL(string: "https://devsci.net/privacy-policy.html") {
            UIApplication.shared.open(url)
        }
    }

}
