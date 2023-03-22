//
//  PreviewImageView.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct PreviewImageView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let item: Item

    static let baseSize = CGSize(width: 384, height: 216)

    private var scaledSize: CGSize {
        return CGSize(
            width: PreviewImageView.baseSize.width * dynamicTypeSize.layoutScalingFactor,
            height: PreviewImageView.baseSize.height * dynamicTypeSize.layoutScalingFactor
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
        Group {
            if item.imageAspectRatio == nil {
                VStack {
                    WebImage(
                        url: item.image,
                        options: [.delayPlaceholder, .lowPriority],
                        context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImageErrorPlaceholderView() }
                        .indicator(.activity)
                        .scaledToFit()
                        .cornerRadius(4)
                        .shadow(color: Color(.separator), radius: 1)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(16/9, contentMode: .fill)
                .padding(8)
                .background(Color(.tertiarySystemFill))
                .cornerRadius(6)
            } else if CGFloat(item.imageWidth) < scaledSize.width || item.imageAspectRatio! < 0.5 {
                VStack {
                    WebImage(
                        url: item.image,
                        options: [.delayPlaceholder, .lowPriority],
                        context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImageErrorPlaceholderView() }
                        .indicator(.activity)
                        .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                        .frame(
                            maxWidth: adjustedItemImageSize.width > 0 ? adjustedItemImageSize.width : nil,
                            maxHeight: adjustedItemImageSize.height > 0 ? min(adjustedItemImageSize.height, 400) : nil,
                            alignment: .center
                        )
                        .clipped()
                        .cornerRadius(4)
                        .shadow(color: Color(.separator), radius: 1)
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color(.tertiarySystemFill))
                .cornerRadius(6)
            } else {
                WebImage(
                    url: item.image,
                    options: [.delayPlaceholder, .lowPriority],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                .resizable()
                .purgeable(true)
                .placeholder { ImageErrorPlaceholderView() }
                .indicator(.activity)
                .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                .frame(
                    maxWidth: adjustedItemImageSize.width > 0 ? adjustedItemImageSize.width : nil,
                    maxHeight: adjustedItemImageSize.height > 0 ? adjustedItemImageSize.height : nil
                )
                .background(Color(.tertiarySystemFill))
                .cornerRadius(6)
                .shadow(color: Color(.separator), radius: 1)
            }
        }
        .grayscale(isEnabled ? 0 : 1)
        .accessibility(label: Text("Preview Image"))
    }
}
