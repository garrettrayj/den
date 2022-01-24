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

        if CommandLine.arguments.contains("--reset") {
            self.resetProfiles()
        } else {
            self.loadProfile()
        }
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
        guard let profileIdString = defaultProfileIdString else {
            do {
                let existingProfiles = try self.viewContext.fetch(Profile.fetchRequest()) as [Profile]
                if let profile = existingProfiles.first {
                    activateProfile(profile)
                } else {
                    let profile = createDefaultProfile()
                    activateProfile(profile)
                }
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
            return
        }

        let fetchRequest = Profile.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", profileIdString)
        do {
            let result = try self.viewContext.fetch(fetchRequest) as [Profile]
            guard let profile = result.first else {
                let profile = createDefaultProfile()
                activateProfile(profile)
                return
            }
            activateProfile(profile)
        } catch {
            crashManager.handleCriticalError(error as NSError)
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
