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
    var images: [RankedImage] = []

    init(workingItem: WorkingItem) {
        self.workingItem = workingItem
    }

    func apply() {
        preconditionFailure("Class missing required override: generateItem()")
    }

    func chooseBestPreviewImage() {
        if let best = images.sorted(by: { a, b in
            a.rank > b.rank
        }).first {
            workingItem.image = best.url
            if let width = best.width, let height = best.height {
                workingItem.imageWidth = Int32(width)
                workingItem.imageHeight = Int32(height)
            }
        }
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
