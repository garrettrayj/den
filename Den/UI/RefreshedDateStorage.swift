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

struct RefreshedDateStorage {
    static private func getProfileKey(_ profileID: String?) -> String? {
        guard let profileID = profileID else { return nil }
        return "ProfileRefreshed_\(profileID)"
    }

    static func getRefreshed(_ profileID: String?) -> Date? {
        guard let profileKey = getProfileKey(profileID) else { return nil }
        let timestamp = UserDefaults.standard.double(forKey: profileKey)
        if timestamp > 0 {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }

    static func setRefreshed(_ profileID: String?, date: Date?) {
        if let profileKey = getProfileKey(profileID) {
            UserDefaults.standard.set(date?.timeIntervalSince1970 ?? nil, forKey: profileKey)
        }
    }
}
