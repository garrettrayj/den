//
//  ProfileSettingsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 6/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

class ProfileSettingsViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    @Published var profile: Profile

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, profile: Profile) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profile = profile
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                NotificationCenter.default.post(name: .profileRefreshed, object: profile.objectID)
            } catch {
                crashManager.handleCriticalError(error as NSError)
            }
        }
    }
}
