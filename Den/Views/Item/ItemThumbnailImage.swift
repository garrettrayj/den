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
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: Item

    static let baseSize = CGSize(width: 64, height: 64)

    private var scaledSize: CGSize {
        return CGSize(
            width: ItemThumbnailImage.baseSize.width * dynamicTypeSize.layoutScalingFactor,
            height: ItemThumbnailImage.baseSize.height * dynamicTypeSize.layoutScalingFactor
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * UIScreen.main.scale,
            height: scaledSize.height * UIScreen.main.scale
        )
    }

    var body: some View {
        if let image = item.image {
            WebImage(
                url: image,
                options: [.decodeFirstFrameOnly, .delayPlaceholder],
                context: [.imageThumbnailPixelSize: thumbnailPixelSize]
            )
                .resizable()
                .purgeable(true)
                .placeholder { ImageErrorPlaceholder() }
                .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                .grayscale(isEnabled ? 0 : 1)
                .overlay(.background.opacity(item.read ? 0.5 : 0))
                .frame(width: scaledSize.width, height: scaledSize.height)
                .background(.quaternary)
                .modifier(ImageBorderModifier(cornerRadius: 6))

        } else if let image = item.feedData?.image {
            ImageDepression(padding: 4) {
                WebImage(
                    url: image,
                    options: [.decodeFirstFrameOnly, .delayPlaceholder],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                .resizable()
                .purgeable(true)
                .placeholder { ImageErrorPlaceholder() }
                .indicator(.activity)
                .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                .grayscale(isEnabled ? 0 : 1)
                .overlay(.background.opacity(item.read ? 0.5 : 0))
                .cornerRadius(4)
            }
            .frame(width: scaledSize.width, height: scaledSize.height)
        }
    }
}
