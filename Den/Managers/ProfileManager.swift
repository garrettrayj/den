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

struct ProfileManager {
    static var defaultProfileIdString: String? {
        get {
            UserDefaults.standard.string(forKey: "ActiveProfile")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "ActiveProfile")
        }
    }

    static func addProfile(context: NSManagedObjectContext) {
        _ = Profile.create(in: context)

        do {
            try context.save()
        } catch let error as NSError {
            CrashManager.handleCriticalError(error)
        }
    }

    static func activateProfile(_ profile: Profile) -> Profile {
        defaultProfileIdString = profile.id?.uuidString
        return profile
    }

    static func loadProfile(context: NSManagedObjectContext, profiles: [Profile]) -> Profile {
        if let profileIdString = defaultProfileIdString {
            if let profileToRestore = profiles.first(where: { profile in
                profile.id?.uuidString == profileIdString
            }) {
                Logger.main.debug("Activating last used profile: \(profileToRestore.wrappedName)")
                return ProfileManager.activateProfile(profileToRestore)
            }
        }

        if let firstProfile = profiles.first {
            Logger.main.debug("Activating first profile found: \(firstProfile.wrappedName)")
            return ProfileManager.activateProfile(firstProfile)
        }

        Logger.main.debug("No profiles available. Creating default")
        let profile = ProfileManager.createDefaultProfile(context: context)
        return ProfileManager.activateProfile(profile)
    }

    static func resetProfiles(context: NSManagedObjectContext) -> Profile {
        let defaultProfile = ProfileManager.activateProfile(
            ProfileManager.createDefaultProfile(context: context)
        )
        let profiles = try? context.fetch(Profile.fetchRequest()) as [Profile]
        for profile in profiles ?? [] where profile != defaultProfile {
            context.delete(profile)
        }
        try? context.save()

        return defaultProfile
    }

    static func createDefaultProfile(context: NSManagedObjectContext) -> Profile {
        let profile = Profile.create(in: context)
        profile.wrappedName = "Den"
        do {
            try context.save()
        } catch {
            CrashManager.handleCriticalError(error as NSError)
        }

        return profile
    }
}
