//
//  SDWebImage+Extensions.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/6/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImage

extension SDWebImageManager {
    func loadImage(
        with url: URL?,
        options: SDWebImageOptions? = nil,
        context: [SDWebImageContextOption: Any]? = nil
    ) async -> (Image?, Data?) {
        return await withCheckedContinuation { continuation in
            SDWebImageManager.shared.loadImage(
                with: url,
                options: options ?? [],
                context: context,
                progress: nil
            ) { image, data, _, _, _, _ in
                var platformImage: Image?
                if let image = image {
                    #if os(macOS)
                    platformImage = Image(nsImage: image)
                    #else
                    platformImage = Image(uiImage: image)
                    #endif
                }
                continuation.resume(returning: (platformImage, data))
            }
        }
    }
}
