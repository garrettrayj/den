//
//  MediaTypeUtility.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson
//

import Foundation

struct MediaTypeUtility {
    static func mediaIsImage(mimeType: String?, medium: String?) -> Bool {
        if let mimeType = mimeType {
            if ImageMIMEType(rawValue: mimeType) != nil {
                return true
            }
        }

        if let medium = medium {
            if medium == "image" {
                return true
            }
        }

        return false
    }
}
