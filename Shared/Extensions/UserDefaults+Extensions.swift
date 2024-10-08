//
//  UserDefaults+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 5/3/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var group: UserDefaults {
        return UserDefaults(suiteName: AppGroup.den.rawValue)!
    }
}
