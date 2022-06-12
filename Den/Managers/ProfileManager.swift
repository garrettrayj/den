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

    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    var profiles: [Profile] {
        do {
            return try viewContext.fetch(Profile.fetchRequest()) as [Profile]
        } catch {
            crashManager.handleCriticalError(error as NSError)
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

        self.loadProfile()
    }

    func addProfile() {
        _ = Profile.create(in: viewContext)

        do {
            try viewContext.save()
            self.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    func activateProfile(_ profile: Profile) {
        guard let profileId = profile.id else {
            crashManager.handleCriticalError(NSError(
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
                self.objectWillChange.send()
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    private func loadProfile() {
        if profiles.isEmpty {
            let profile = createDefaultProfile()
            activateProfile(profile)
            return
        }

        if let profileIdString = defaultProfileIdString {
            if let profileToRestore = profiles.first(where: { profile in
                profile.id?.uuidString == profileIdString
            }) {
                activateProfile(profileToRestore)
                return
            }
        }

        if let firstProfile = profiles.first {
            activateProfile(firstProfile)
        }
    }

    private func createDefaultProfile() -> Profile {
        let profile = Profile.create(in: viewContext)
        profile.wrappedName = "Den"

        do {
            try viewContext.save()
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }

        return profile
    }
}
