//
//  ImageSelection.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

class ImageSelection {
    var image: URL?
    var imageWidth: Int32?
    var imageHeight: Int32?

    var imagePool: [RankedImage] = []

    func selectImage() {
        if let best = imagePool.topRanked {
            image = best.url
            if let width = best.width, let height = best.height {
                imageWidth = Int32(width)
                imageHeight = Int32(height)
            }
        }
    }
}
