//
//  Bundle+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 9/9/20.
//  Copyright © 2020 Garrett Johnson
//

import Foundation

extension Bundle {
    var name: String {
        return infoDictionary!["CFBundleName"] as? String ?? "NA"
    }

    var releaseVersionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "NA"
    }

    var buildVersionNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }

    var copyright: String {
        return infoDictionary?["NSHumanReadableCopyright"] as? String ?? "NA"
    }
}
