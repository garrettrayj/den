//
//  ItemPreviewImage.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct ItemPreviewImage: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var item: Item

    static let baseSize = CGSize(width: 384, height: 216)

    private var scaledSize: CGSize {
        return CGSize(
            width: ItemPreviewImage.baseSize.width * dynamicTypeSize.layoutScalingFactor,
            height: ItemPreviewImage.baseSize.height * dynamicTypeSize.layoutScalingFactor
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * UIScreen.main.scale,
            height: scaledSize.height * UIScreen.main.scale
        )
    }

    var body: some View {
        Group {
            if item.imageAspectRatio == nil {
                ImageDepression(padding: 8) {
                    WebImage(
                        url: item.image,
                        options: [.delayPlaceholder, .lowPriority],
                        context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImageErrorPlaceholder() }
                        .indicator(.activity)
                        .grayscale(isEnabled ? 0 : 1)
                        .overlay(.background.opacity(item.read ? 0.5 : 0))
                        .modifier(ImageBorderModifier(cornerRadius: 4))
                        .scaledToFit()
                }
                .aspectRatio(16/9, contentMode: .fill)
            } else if CGFloat(item.imageWidth) < scaledSize.width || item.imageAspectRatio! < 0.5 {
                ImageDepression(padding: 8) {
                    WebImage(
                        url: item.image,
                        options: [.delayPlaceholder, .lowPriority],
                        context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImageErrorPlaceholder() }
                        .indicator(.activity)
                        .grayscale(isEnabled ? 0 : 1)
                        .overlay(.background.opacity(item.read ? 0.5 : 0))
                        .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                        .frame(
                            maxHeight: scaledSize.height > 0 ? min(scaledSize.height, 400) : nil,
                            alignment: .top
                        )
                        .clipped()
                        .modifier(ImageBorderModifier(cornerRadius: 4))
                }
            } else {
                WebImage(
                    url: item.image,
                    options: [.delayPlaceholder, .lowPriority],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                .resizable()
                .purgeable(true)
                .placeholder { ImageErrorPlaceholder() }
                .indicator(.activity)
                .grayscale(isEnabled ? 0 : 1)
                .overlay(.background.opacity(item.read ? 0.5 : 0))
                .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                .frame(
                    maxWidth: scaledSize.width,
                    maxHeight: scaledSize.height
                )
                .background(.quaternary)
                .modifier(ImageBorderModifier())
            }
        }
        .accessibility(label: Text("Preview Image"))
    }
}
