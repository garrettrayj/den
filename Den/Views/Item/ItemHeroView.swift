//
//  ItemHeroView.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct ItemHeroView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: Item

    static let baseSize = CGSize(width: 800, height: 450)

    private var scaledSize: CGSize {
        return CGSize(
            width: ItemHeroView.baseSize.width * dynamicTypeSize.layoutScalingFactor,
            height: ItemHeroView.baseSize.height * dynamicTypeSize.layoutScalingFactor
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * UIScreen.main.scale,
            height: scaledSize.height * UIScreen.main.scale
        )
    }

    private var adjustedItemImageSize: CGSize {
        // Small images scale with dynamic type size even though bluring is likely
        if CGFloat(item.imageWidth) < scaledSize.width {
            return CGSize(
                width: CGFloat(item.imageWidth) * dynamicTypeSize.layoutScalingFactor,
                height: CGFloat(item.imageHeight) * dynamicTypeSize.layoutScalingFactor
            )
        }

        return CGSize(
            width: CGFloat(item.imageWidth),
            height: CGFloat(item.imageHeight)
        )
    }

    var body: some View {
        if item.imageAspectRatio == nil {
            ImageDepressionView {
                WebImage(
                    url: item.image,
                    options: [.delayPlaceholder],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                .resizable()
                .placeholder { ImageErrorPlaceholderView() }
                .indicator(.activity)
                .scaledToFit()
                .modifier(ImageBorderModifier(cornerRadius: 4))
            }
            .aspectRatio(16/9, contentMode: .fill)
        } else if CGFloat(item.imageWidth) < ItemHeroView.baseSize.width {
            ImageDepressionView {
                WebImage(
                    url: item.image,
                    options: [.delayPlaceholder],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                .resizable()
                .placeholder { ImageErrorPlaceholderView() }
                .indicator(.activity)
                .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                .frame(
                    maxWidth: adjustedItemImageSize.width > 0 ? adjustedItemImageSize.width : nil,
                    maxHeight: adjustedItemImageSize.height > 0 ? adjustedItemImageSize.height : nil
                )
                .modifier(ImageBorderModifier(cornerRadius: 4))
            }
            .scaledToFit()
        } else {
            WebImage(
                url: item.image,
                options: [.delayPlaceholder],
                context: [.imageThumbnailPixelSize: thumbnailPixelSize]
            )
                .resizable()
                .placeholder { ImageErrorPlaceholderView() }
                .indicator(.activity)
                .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                .background(Color(.tertiarySystemFill))
                .modifier(ImageBorderModifier())
        }
    }
}
