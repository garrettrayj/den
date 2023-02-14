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
            width: PreviewImageView.baseSize.width * dynamicTypeSize.fontScale,
            height: PreviewImageView.baseSize.height * dynamicTypeSize.fontScale
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
                    WebImage(url: item.image, context: [.imageThumbnailPixelSize: thumbnailPixelSize])
                        .resizable()
                        .purgeable(true)
                        .placeholder {
                            ItemImagePlaceholderView()
                        }
                        .scaledToFit()
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Color(uiColor: .separator)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(16/9, contentMode: .fill)
                .padding(8)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(6)
            } else if CGFloat(item.imageWidth) < scaledSize.width || item.imageAspectRatio! < 0.5 {
                VStack {
                    WebImage(url: item.image, context: [.imageThumbnailPixelSize: thumbnailPixelSize])
                        .resizable()
                        .purgeable(true)
                        .placeholder {
                            ItemImagePlaceholderView()
                        }
                        .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                        .frame(
                            maxWidth: adjustedItemImageSize.width > 0 ? adjustedItemImageSize.width : nil,
                            maxHeight: adjustedItemImageSize.height > 0 ? adjustedItemImageSize.height : nil
                        )
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Color(uiColor: .separator)))
                }
                .frame(maxWidth: .infinity, maxHeight: 400, alignment: .top)
                .clipped()
                .padding(8)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(6)
            } else {
                WebImage(url: item.image, context: [.imageThumbnailPixelSize: thumbnailPixelSize])
                    .resizable()
                    .purgeable(true)
                    .placeholder {
                        ItemImagePlaceholderView()
                    }
                    .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                    .frame(
                        maxWidth: adjustedItemImageSize.width > 0 ? adjustedItemImageSize.width : nil,
                        maxHeight: adjustedItemImageSize.height > 0 ? adjustedItemImageSize.height : nil
                    )
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Color(uiColor: .separator)))
            }
        }
        .grayscale(isEnabled ? 0 : 1)
        .accessibility(label: Text("Preview image"))
    }
}
