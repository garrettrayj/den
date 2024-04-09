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
    
    static let refreshedKey = "Refreshed"

    static func getRefreshed() -> Date? {
        let timestamp = UserDefaults.standard.double(forKey: refreshedKey)
        if timestamp > 0 {
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }

    static func setRefreshed(date: Date?) {
        UserDefaults.standard.set(date?.timeIntervalSince1970 ?? nil, forKey: refreshedKey)
    }
}
