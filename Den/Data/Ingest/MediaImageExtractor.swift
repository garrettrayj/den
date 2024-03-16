//
//  MediaImageExtractor.swift
//  Den
//
//  Created by Garrett Johnson on 3/16/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import FeedKit

struct MediaImageExtractor {
    static func extractImages(
        mediaNamespace: MediaNamespace,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        extractMediaContentImages(
            mediaNamespace: mediaNamespace,
            itemLink: itemLink,
            imagePool: &imagePool
        )
        extractMediaGroupImages(
            mediaNamespace: mediaNamespace,
            itemLink: itemLink,
            imagePool: &imagePool
        )
        extractMediaThumbnailsImages(
            mediaNamespace: mediaNamespace,
            itemLink: itemLink,
            imagePool: &imagePool
        )
    }
    
    /// Extract images from <media:content>
    static func extractMediaContentImages(
        mediaNamespace: MediaNamespace,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard let mediaContents = mediaNamespace.mediaContents else { return }
        
        for media in mediaContents {
            if
                let urlString = media.attributes?.url,
                let url = URL(string: urlString, relativeTo: itemLink),
                MediaTypeUtility.mediaIsImage(
                    mimeType: media.attributes?.type,
                    medium: media.attributes?.medium
                )
            {
                if
                    let width = media.attributes?.width,
                    let height = media.attributes?.height
                {
                    imagePool.append(PreliminaryImage(
                        url: url.absoluteURL,
                        width: width,
                        height: height
                    ))
                } else {
                    imagePool.append(PreliminaryImage(url: url.absoluteURL))
                }
            }
        }
    }

    static func extractMediaGroupImages(
        mediaNamespace: MediaNamespace,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard let mediaGroupContents = mediaNamespace.mediaGroup?.mediaContents else { return }
        
        for media in mediaGroupContents {
            if
                let urlString = media.attributes?.url,
                let url = URL(string: urlString, relativeTo: itemLink),
                MediaTypeUtility.mediaIsImage(
                    mimeType: media.attributes?.type,
                    medium: media.attributes?.medium
                )
            {
                if
                    let width = media.attributes?.width,
                    let height = media.attributes?.height
                {
                    imagePool.append(PreliminaryImage(
                        url: url.absoluteURL,
                        width: width,
                        height: height
                    ))
                } else {
                    imagePool.append(PreliminaryImage(url: url.absoluteURL))
                }
            }
        }
    }

    static func extractMediaThumbnailsImages(
        mediaNamespace: MediaNamespace,
        itemLink: URL,
        imagePool: inout [PreliminaryImage]
    ) {
        guard let thumbnails = mediaNamespace.mediaThumbnails else { return }
        
        for thumbnail in thumbnails {
            if
                let urlString = thumbnail.attributes?.url,
                let url = URL(string: urlString, relativeTo: itemLink)
            {
                if
                    let width = Int(thumbnail.attributes?.width ?? ""),
                    let height = Int(thumbnail.attributes?.height ?? "")
                {
                    imagePool.append(PreliminaryImage(
                        url: url.absoluteURL,
                        width: width,
                        height: height
                    ))
                } else {
                    imagePool.append(PreliminaryImage(url: url.absoluteURL))
                }
            }
        }
    }
}
