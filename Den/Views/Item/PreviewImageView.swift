//
//  PreviewImageView.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct PreviewImageView: View {
    let item: Item

    var body: some View {
        Group {
            if item.imageAspectRatio == nil {
                VStack {
                    WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.preview])
                        .resizable()
                        .purgeable(true)
                        .placeholder {
                            ItemImagePlaceholderView(imageURL: item.image, aspectRatio: 16/9)
                        }
                        .scaledToFit()
                        .cornerRadius(4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(16/9, contentMode: .fill)
                .padding(8)
            } else if CGFloat(item.imageWidth) < ImageSize.preview.width {
                VStack {
                    WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.preview])
                        .resizable()
                        .purgeable(true)
                        .placeholder {
                            ItemImagePlaceholderView(imageURL: item.image, aspectRatio: 16/9)
                        }
                        .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                        .cornerRadius(4)
                        .frame(
                            maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                            maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(8)
            } else {
                WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.preview])
                    .resizable()
                    .purgeable(true)
                    .placeholder {
                        ItemImagePlaceholderView(imageURL: item.image, aspectRatio: item.imageAspectRatio, padding: 8)
                    }
                    .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                    .frame(
                        maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                        maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
                    )
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(6)
        .accessibility(label: Text("Preview image"))
    }
}
