//
//  ItemTransform.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

class ItemTransform {
    var workingItem: WorkingItem
    var images: [WorkingItemImage] = []

    init(workingItem: WorkingItem) {
        self.workingItem = workingItem
    }

    func apply() {
        preconditionFailure("Class missing required override: generateItem()")
    }

    func chooseBestPreviewImage() {
        workingItem.image = images.sorted { a, b in
            a.rank > b.rank
        }.first?.url
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
