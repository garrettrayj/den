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
            width: ItemHeroView.baseSize.width * dynamicTypeSize.fontScale,
            height: ItemHeroView.baseSize.height * dynamicTypeSize.fontScale
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
                width: CGFloat(item.imageWidth) * dynamicTypeSize.fontScale,
                height: CGFloat(item.imageHeight) * dynamicTypeSize.fontScale
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
                        options: [.delayPlaceholder],
                        context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImagePlaceholderView() }
                        .indicator(.activity)
                        .scaledToFit()
                        .cornerRadius(4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(16/9, contentMode: .fill)
                .padding(8)
            } else if CGFloat(item.imageWidth) < ItemHeroView.baseSize.width {
                VStack {
                    WebImage(
                        url: item.image,
                        options: [.delayPlaceholder],
                        context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImagePlaceholderView() }
                        .indicator(.activity)
                        .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                        .cornerRadius(4)
                        .frame(
                            maxWidth: adjustedItemImageSize.width > 0 ? adjustedItemImageSize.width : nil,
                            maxHeight: adjustedItemImageSize.height > 0 ? adjustedItemImageSize.height : nil
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(8)
            } else {
                WebImage(
                    url: item.image,
                    options: [.delayPlaceholder],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                    .resizable()
                    .placeholder { ImagePlaceholderView() }
                    .indicator(.activity)
                    .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
                    )
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(6)
    }
}
