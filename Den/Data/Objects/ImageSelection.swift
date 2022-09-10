//
//  ImageSelection.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

class ImageSelection {
    var image: URL?
    var imageWidth: Int32?
    var imageHeight: Int32?

    var imagePool: [RankedImage] = []

    func topRankedImage() -> RankedImage? {
        imagePool.sorted(by: { a, b in
            a.rank > b.rank
        }).first
    }

    func selectImage() {
        if let best = topRankedImage() {
            image = best.url
            if let width = best.width, let height = best.height {
                imageWidth = Int32(width)
                imageHeight = Int32(height)
            }
        }
    }
}
