//
//  SmallThumbnail.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

import SDWebImageSwiftUI

struct SmallThumbnail: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.smallThumbnailSize) private var smallThumbnailSize
    @Environment(\.smallThumbnailPixelSize) private var smallThumbnailPixelSize

    let url: URL
    let isRead: Bool

    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly, .delayPlaceholder, .lowPriority],
            context: [.imageThumbnailPixelSize: smallThumbnailPixelSize]
        )
        .purgeable(true)
        .resizable()
        .placeholder { ImageErrorPlaceholder() }
        .modifier(PreviewImageStateModifier(isRead: isRead))
        .scaledToFill()
        .frame(width: smallThumbnailSize.width, height: smallThumbnailSize.height)
        .background(.quaternary)
        .modifier(ImageBorderModifier(cornerRadius: 6))
    }
}
