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

    let item: Item

    var body: some View {
        Group {
            if item.imageAspectRatio == nil {
                VStack {
                    WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.preview])
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
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(6)
            } else if CGFloat(item.imageWidth) < ImageSize.preview.width {
                VStack {
                    WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.preview])
                        .resizable()
                        .purgeable(true)
                        .placeholder {
                            ItemImagePlaceholderView()
                        }
                        .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                        .frame(
                            maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                            maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil
                        )
                        .cornerRadius(4)
                        .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Color(uiColor: .separator)))
                }
                .frame(maxWidth: .infinity)
                .padding(8)
                .background(Color(UIColor.secondarySystemFill))
                .cornerRadius(6)
            } else {
                WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.preview])
                    .resizable()
                    .purgeable(true)
                    .placeholder {
                        ItemImagePlaceholderView()
                    }
                    .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                    .frame(
                        maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                        maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil
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
