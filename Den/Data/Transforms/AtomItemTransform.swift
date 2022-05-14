//
//  AtomItemTransform.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation
import FeedKit

final class AtomItemTransform: ItemTransform {
    let entry: AtomFeedEntry

    init(workingItem: WorkingItem, entry: AtomFeedEntry) {
        self.entry = entry

        super.init(workingItem: workingItem)
    }

    override func apply() {
        populateGeneralProperties()
        populateSummary()
        findLinkImages()
        findMediaContentImages()
        findMediaThumbnailsImages()
        findContentImages()
        findSummaryImages()

        chooseBestPreviewImage()
    }

    private func populateGeneralProperties() {
        workingItem.link = entry.linkURL

        if let published = entry.published {
            workingItem.published = published
        } else if let published = entry.updated {
            workingItem.published = published
        }

        if let title = entry.title?.preparingTitle() {
            workingItem.title = title
        } else {
            workingItem.title = "Untitled"
        }
    }

    private func populateSummary() {
        // Extract plain text from summary or content
        if let source = entry.summary?.value?.htmlUnescape() {
            workingItem.summary = SummaryHTML(source).plainText()
        } else if let source = entry.content?.value?.htmlUnescape() {
            workingItem.summary = SummaryHTML(source).plainText()
        }
    }

    private func findLinkImages() {
        if
            let link = entry.links?.first(where: { link in
                link.attributes?.rel == "enclosure"
            }),
            let urlString = link.attributes?.href,
            let url = URL(string: urlString, relativeTo: workingItem.link),
            let mimeType = link.attributes?.type,
            ImageMIMEType(rawValue: mimeType) != nil {
            self.images.append(
                RankedImage(
                    url: url.absoluteURL,
                    rank: Int(ImageSize.thumbnail.area) + 3
                )
            )
        }

    }

    private func findMediaContentImages() {
        if let mediaContents = entry.media?.mediaContents {
            for media in mediaContents {
                if
                    let urlString = media.attributes?.url,
                    let url = URL(string: urlString, relativeTo: workingItem.link),
                    mediaIsImage(mimeType: media.attributes?.type, medium: media.attributes?.medium)
                {
                    if
                        let width = media.attributes?.width,
                        let height = media.attributes?.height
                    {
                        images.append(RankedImage(
                            url: url.absoluteURL,
                            rank: width * height,
                            width: width,
                            height: height
                        ))
                    } else {
                        images.append(RankedImage(url: url))
                    }
                }
            }
        }
    }

    private func findMediaThumbnailsImages() {
        // Extract images from <media:thumbnails>
        if let thumbnails = entry.media?.mediaThumbnails {
            for thumbnail in thumbnails {
                if
                    let urlString = thumbnail.attributes?.url,
                    let url = URL(string: urlString, relativeTo: workingItem.link)
                {
                    if
                        let width = Int(thumbnail.attributes?.width ?? ""),
                        let height = Int(thumbnail.attributes?.height ?? "")
                    {
                        images.append(RankedImage(
                            url: url.absoluteURL,
                            rank: width * height,
                            width: width,
                            height: height
                        ))
                    } else {
                        images.append(RankedImage(url: url.absoluteURL))
                    }
                }
            }
        }
    }

    private func findContentImages() {
        if let source = entry.content?.value?.htmlUnescape() {
            if let allowedImages = SummaryHTML(source).allowedImages(itemLink: workingItem.link) {
                images.append(contentsOf: allowedImages)
            }
        }
    }

    private func findSummaryImages() {
        if let source = entry.summary?.value?.htmlUnescape() {
            if let allowedImages = SummaryHTML(source).allowedImages(itemLink: workingItem.link) {
                images.append(contentsOf: allowedImages)
            }
        }
    }
}
