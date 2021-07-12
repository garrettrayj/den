//
//  ProfileManager.swift
//  Den
//
//  Created by Garrett Johnson on 6/27/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var activeProfile: Profile?

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager

        loadProfiles()
    }

    private func loadProfiles() {
        do {
            profiles = try self.viewContext.fetch(Profile.fetchRequest()) as [Profile]
            if profiles.count == 0 {
                profiles.append(createDefault(adoptOrphans: true))
            }
            activeProfile = profiles.first
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    private func createDefault(adoptOrphans: Bool = false) -> Profile {
        let defaultProfile = Profile.create(in: viewContext)

        if adoptOrphans == true {
            // Adopt existing pages and history for profile upgrade
            do {
                let history = try self.viewContext.fetch(History.fetchRequest()) as [History]
                history.forEach { visit in
                    defaultProfile.addToHistory(visit)
                }
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }

            do {
                let pages = try self.viewContext.fetch(Page.fetchRequest()) as [Page]
                pages.forEach { page in
                    defaultProfile.addToPages(page)
                }
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }

        do {
            try viewContext.save()
            profiles.append(defaultProfile)
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }

        return defaultProfile
    }

    public func resetProfiles() {
        let defaultProfile = createDefault()
        activeProfile = defaultProfile

        profiles.forEach { profile in
            if profile != defaultProfile {
                viewContext.delete(profile)
            }
        }

        do {
            try viewContext.save()
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
