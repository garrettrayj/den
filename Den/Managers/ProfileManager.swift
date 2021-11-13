//
//  ProfileManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

final class ProfileManager: ObservableObject {
    @Published var activeProfile: Profile?

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager

        if CommandLine.arguments.contains("--reset") {
            self.resetProfiles()
        } else {
            self.loadProfiles()
        }
    }

    func resetProfiles() {
        activeProfile = createDefaultProfile()

        do {
            let profiles = try self.viewContext.fetch(Profile.fetchRequest()) as [Profile]
            profiles.forEach { profile in
                if profile != activeProfile {
                    viewContext.delete(profile)
                }
            }
            do {
                try viewContext.save()
                self.objectWillChange.send()
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    private func loadProfiles() {
        do {
            let profiles = try self.viewContext.fetch(Profile.fetchRequest()) as [Profile]
            if profiles.count == 0 {
                activeProfile = createDefaultProfile(adoptOrphans: true)
            } else {
                activeProfile = profiles.first
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    private func createDefaultProfile(adoptOrphans: Bool = false) -> Profile {
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
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }

        return defaultProfile
    }
}
