//
//  MIMETypes.swift
//  Den
//
//  Created by Garrett Johnson on 7/11/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

enum ImageMIMEType: String, CaseIterable {
    case icon = "image/x-icon"
    case msicon = "image/vnd.microsoft.icon"
    case png = "image/png"
    case apng = "image/apng"
    case jpeg = "image/jpeg"
    case gif = "image/gif"
    case webp = "image/webp"
    case svg = "image/svg+xml"
    // Cover incorrect JPEG MIME type usage,
    // e.g. images in Raw Story feeds (https://www.rawstory.com/category/world/feed/)
    case jpg = "image/jpg"
    case generic = "image/*"
    case all = "*/*;q=0.8"
}
