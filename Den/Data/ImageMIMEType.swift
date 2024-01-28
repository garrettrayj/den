//
//  ImageMIMEType.swift
//  Den
//
//  Created by Garrett Johnson on 7/11/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import Foundation

enum ImageMIMEType: String, CaseIterable {
    case icon    = "image/x-icon"
    case msicon  = "image/vnd.microsoft.icon"
    case bmp     = "image/bmp"
    case png     = "image/png"
    case apng    = "image/apng"
    case jpeg    = "image/jpeg"
    case gif     = "image/gif"
    case webp    = "image/webp"
    case svg     = "image/svg+xml"
    case jpg     = "image/jpg" // Allow incorrect JPEG MIME type usage
    case generic = "image/*"
    case all     = "*/*;q=0.8"
}
