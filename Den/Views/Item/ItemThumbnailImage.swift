//
//  ItemThumbnailImage.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct ItemThumbnailImage: View {
    @Environment(\.displayScale) private var displayScale
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let url: URL
    let isRead: Bool
    let aspectRatio: CGFloat?

    static let baseSize = CGSize(width: 64, height: 64)

    private var scaledSize: CGSize {
        CGSize(
            width: ItemThumbnailImage.baseSize.width * dynamicTypeSize.layoutScalingFactor,
            height: ItemThumbnailImage.baseSize.height * dynamicTypeSize.layoutScalingFactor
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * displayScale,
            height: scaledSize.height * displayScale
        )
    }

    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly, .delayPlaceholder],
            context: [.imageThumbnailPixelSize: thumbnailPixelSize]
        )
        .resizable()
        .placeholder { ImageErrorPlaceholder() }
        .aspectRatio(aspectRatio, contentMode: .fill)
        .grayscale(isEnabled ? 0 : 1)
        .overlay(.background.opacity(isRead ? 0.5 : 0))
        .frame(width: scaledSize.width, height: scaledSize.height)
        .background(.quaternary)
        .modifier(ImageBorderModifier(cornerRadius: 6))
    }
}
