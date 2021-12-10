//
//  Bundle+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 9/9/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "NA"
    }

    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }
}
