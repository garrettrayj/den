//
//  SmallThumbnail.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

import SDWebImageSwiftUI

struct SmallThumbnail: View {
    @Environment(\.smallThumbnailSize) private var smallThumbnailSize
    @Environment(\.smallThumbnailPixelSize) private var smallThumbnailPixelSize

    let url: URL
    let isRead: Bool

    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly],
            context: [.imageThumbnailPixelSize: smallThumbnailPixelSize]
        ) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            ImageErrorPlaceholder()
        }
        .modifier(PreviewImageStateModifier(isRead: isRead))
        .frame(width: smallThumbnailSize.width, height: smallThumbnailSize.height)
        .background(.fill.tertiary)
        .modifier(ImageBorderModifier(cornerRadius: 6))
    }
}
