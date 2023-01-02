//
//  ProfileUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI

struct ProfileUtility {
    static func createDefaultProfile(context: NSManagedObjectContext) -> Profile {
        let profile = Profile.create(in: context)
        profile.wrappedName = "Den"

        do {
            try context.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }

        return profile
    }
}
