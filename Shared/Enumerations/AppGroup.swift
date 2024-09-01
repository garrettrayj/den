//
//  AppGroup.swift
//  Shared
//
//  Created by Garrett Johnson on 4/29/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import Foundation

public enum AppGroup: String {
    case den = "group.net.devsci.den"

    public var containerURL: URL? {
        switch self {
        case .den:
            return FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: self.rawValue
            )
        }
    }
}
