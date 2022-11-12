//
//  ImageSize.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ImageSize {
    static let favicon = CGSize(width: 16, height: 16)
    static let preview = CGSize(width: 396, height: 264)
    static let thumbnail = CGSize(width: 72, height: 72)
    static let full = CGSize(width: 800, height: 450)
}

struct ImageReferenceSize {
    static let favicon = CGSize(
        width: ImageSize.favicon.width * UIScreen.main.scale,
        height: ImageSize.favicon.height * UIScreen.main.scale
    )
    static let preview = CGSize(
        width: ImageSize.preview.width * UIScreen.main.scale,
        height: ImageSize.preview.height * UIScreen.main.scale
    )
    static let thumbnail = CGSize(
        width: ImageSize.thumbnail.width * UIScreen.main.scale,
        height: ImageSize.thumbnail.height * UIScreen.main.scale
    )
    static let full = CGSize(
        width: ImageSize.full.width * UIScreen.main.scale,
        height: ImageSize.full.height * UIScreen.main.scale
    )
}
