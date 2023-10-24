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
        .resizable()
        .placeholder { ImageErrorPlaceholder() }
        .grayscale(isEnabled ? 0 : 1)
        .scaledToFill()
        .frame(width: smallThumbnailSize.width, height: smallThumbnailSize.height)
        .background(.quaternary)
        .overlay(.background.opacity(isRead ? 0.5 : 0))
        .modifier(ImageBorderModifier(cornerRadius: 6))
    }
}
