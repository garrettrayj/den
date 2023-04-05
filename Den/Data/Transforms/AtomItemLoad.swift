//
//  AtomItemLoad.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import FeedKit

struct AtomItemLoad {
    let item: Item
    let source: AtomFeedEntry
    let imageSelection = ImageSelection()

    func apply() {
        populateGeneralProperties()
        populateText()
        findMediaContentImages()
        findMediaThumbnailsImages()
        findContentImages()
        findSummaryImages()

        imageSelection.selectImage()
        item.image = imageSelection.image
        item.imageWidth = imageSelection.imageWidth ?? 0
        item.imageHeight = imageSelection.imageHeight ?? 0
    }

    private func populateGeneralProperties() {
        item.link = source.linkURL

        if let published = source.published {
            item.published = published
        } else if let published = source.updated {
            item.published = published
        }

        if let title = source.title?.preparingTitle() {
            item.title = title
        } else {
            item.title = "Untitled"
        }

        if let author = source.authors?.first?.name {
            let formattedAuthor = author.preparingTitle()
            if formattedAuthor != "" {
                item.author = formattedAuthor
            }
        }
    }

    private func populateText() {
        if let summary = source.summary?.value?.htmlUnescape() {
            item.summary = HTMLContent(summary).sanitizedHTML()
        } else if let summary = source.content?.value?.htmlUnescape() {
            item.summary = HTMLContent(summary).sanitizedHTML()
        }

        if let teaser = item.summary {
            item.teaser = HTMLContent(teaser).plainText()?.truncated(limit: 1000)
        }

        if let body = source.content?.value {
            item.body = HTMLContent(body).sanitizedHTML()
        }
    }

    private func findLinkImages() {
        if
            let link = source.links?.first(where: { link in
                link.attributes?.rel == "enclosure"
            }),
            let urlString = link.attributes?.href,
            let url = URL(string: urlString, relativeTo: item.link),
            let mimeType = link.attributes?.type,
            ImageMIMEType(rawValue: mimeType) != nil {
            self.imageSelection.imagePool.append(
                RankedImage(
                    url: url.absoluteURL,
                    rank: Int(ItemThumbnailImage.baseSize.area) + 3
                )
            )
        }

    }

    private func findMediaContentImages() {
        if let mediaContents = source.media?.mediaContents {
            for media in mediaContents {
                if
                    let urlString = media.attributes?.url,
                    let url = URL(string: urlString, relativeTo: item.link),
                    MediaTypeUtility.mediaIsImage(mimeType: media.attributes?.type, medium: media.attributes?.medium)
                {
                    if
                        let width = media.attributes?.width,
                        let height = media.attributes?.height
                    {
                        imageSelection.imagePool.append(RankedImage(
                            url: url.absoluteURL,
                            rank: width * height,
                            width: width,
                            height: height
                        ))
                    } else {
                        imageSelection.imagePool.append(RankedImage(
                            url: url,
                            rank: Int(ItemPreviewImage.baseSize.area)
                        ))
                    }
                }
            }
        }
    }

    private func findMediaThumbnailsImages() {
        // Extract images from <media:thumbnails>
        if let thumbnails = source.media?.mediaThumbnails {
            for thumbnail in thumbnails {
                if
                    let urlString = thumbnail.attributes?.url,
                    let url = URL(string: urlString, relativeTo: item.link)
                {
                    if
                        let width = Int(thumbnail.attributes?.width ?? ""),
                        let height = Int(thumbnail.attributes?.height ?? "")
                    {
                        imageSelection.imagePool.append(RankedImage(
                            url: url.absoluteURL,
                            rank: width * height,
                            width: width,
                            height: height
                        ))
                    } else {
                        imageSelection.imagePool.append(RankedImage(
                            url: url.absoluteURL,
                            rank: Int(ItemThumbnailImage.baseSize.area)
                        ))
                    }
                }
            }
        }
    }

    private func findContentImages() {
        if let source = source.content?.value?.htmlUnescape() {
            if let allowedImages = HTMLContent(source).allowedImages(itemLink: item.link) {
                imageSelection.imagePool.append(contentsOf: allowedImages)
            }
        }
    }

    private func findSummaryImages() {
        if let source = source.summary?.value?.htmlUnescape() {
            if let allowedImages = HTMLContent(source).allowedImages(itemLink: item.link) {
                imageSelection.imagePool.append(contentsOf: allowedImages)
            }
        }
    }
}
