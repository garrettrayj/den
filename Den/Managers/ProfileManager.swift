//
//  ProfileManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import OSLog

final class ProfileManager: ObservableObject {
    @Published var activeProfile: Profile?

    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    var profiles: [Profile] {
        do {
            return try viewContext.fetch(Profile.fetchRequest()) as [Profile]
        } catch {
            CrashManager.handleCriticalError(error as NSError)
            return []
        }
    }

    var defaultProfileIdString: String? {
        get {
            UserDefaults.standard.string(forKey: "ActiveProfile")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ActiveProfile")
        }
    }

    var activeProfileName: String {
        activeProfile?.wrappedName ?? "Unknown"
    }

    var activeProfileIsEmpty: Bool {
        activeProfile?.pagesArray.isEmpty ?? true
    }

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager
    }

    func addProfile() {
        _ = Profile.create(in: viewContext)

        do {
            try viewContext.save()
            self.objectWillChange.send()
        } catch let error as NSError {
            CrashManager.handleCriticalError(error)
        }
    }

    func activateProfile(_ profile: Profile) {
        guard let profileId = profile.id else {
            CrashManager.handleCriticalError(NSError(
                domain: "profile",
                code: 2,
                userInfo: ["message": "Default profile ID unavailable"]
            ))
            return
        }

        defaultProfileIdString = profileId.uuidString
        activeProfile = profile
    }

    func resetProfiles() {
        let defaultProfile = createDefaultProfile()
        activateProfile(defaultProfile)

        do {
            let profiles = try self.viewContext.fetch(Profile.fetchRequest()) as [Profile]
            profiles.forEach { profile in
                if profile != activeProfile {
                    viewContext.delete(profile)
                }
            }
            do {
                try viewContext.save()
            } catch {
                CrashManager.handleCriticalError(error as NSError)
            }
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }
    }

    func loadProfile() {
        guard activeProfile == nil else {
            Logger.main.debug("Active profile: \(self.activeProfile!.wrappedName)")
            return
        }

        if profiles.isEmpty {
            Logger.main.debug("No profiles available. Creating default")
            let profile = createDefaultProfile()
            activateProfile(profile)
            return
        }

        if let profileIdString = defaultProfileIdString {
            if let profileToRestore = profiles.first(where: { profile in
                profile.id?.uuidString == profileIdString
            }) {
                Logger.main.debug("Activating last used profile: \(profileToRestore.wrappedName)")
                activateProfile(profileToRestore)
                return
            }
        }

        if let firstProfile = profiles.first {
            Logger.main.debug("Activating first profile found: \(firstProfile.wrappedName)")
            activateProfile(firstProfile)
        }
    }

    private func createDefaultProfile() -> Profile {
        let profile = Profile.create(in: viewContext)
        profile.wrappedName = "Den"

        do {
            try viewContext.save()
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }

        return profile
    }
}
