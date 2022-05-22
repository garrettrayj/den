//
//  ItemTransform.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

class ItemTransform {
    let workingItem: WorkingItem

    init(workingItem: WorkingItem) {
        self.workingItem = workingItem
    }

    func apply() {
        preconditionFailure("Class missing required override: apply()")
    }

    func mediaIsImage(mimeType: String?, medium: String?) -> Bool {
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
