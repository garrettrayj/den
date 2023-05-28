//
//  RefreshedDateUtility.swift
//  Den
//
//  Created by Garrett Johnson on 2/25/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

final class RefreshedDateStorage: ObservableObject {
    static let shared = RefreshedDateStorage()

    private func getProfileKey(_ profile: Profile) -> String? {
        guard let profileID = profile.id?.uuidString else { return nil }
        return "ProfileRefreshed_\(profileID)"
    }

    func getRefreshed(_ profile: Profile) -> Date? {
        guard let profileKey = getProfileKey(profile) else { return nil }
        let timestamp = UserDefaults.standard.double(forKey: profileKey)
        if timestamp > 0 {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }

    func setRefreshed(_ profile: Profile, date: Date?) {
        if let profileKey = getProfileKey(profile) {
            UserDefaults.standard.set(date?.timeIntervalSince1970 ?? nil, forKey: profileKey)
        }
    }
}
