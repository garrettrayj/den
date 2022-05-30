//
//  RSSItemTransform.swift
//  Den
//
//  Created by Garrett Johnson on 1/23/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation
import FeedKit

final class RSSItemTransform: ItemTransform {
    let rssItem: RSSFeedItem

    init(workingItem: WorkingItem, rssItem: RSSFeedItem) {
        self.rssItem = rssItem
        super.init(workingItem: workingItem)
    }

    override func apply() {
        populateGeneralProperties()
        populateSummary()
        findEnclosureImage()
        findMediaContentImages()
        findMediaGroupImages()
        findMediaThumbnailsImages()
        findContentImages()
        findDescriptionImages()

        workingItem.selectImage()
    }

    private func populateGeneralProperties() {
        // Prefer RSS pubDate element for published date
        if let published = rssItem.pubDate {
            workingItem.published = published
        } else {
            // Fallback to Dublin Core metadata for published date
            // (ex. http://feeds.feedburner.com/oatmealfeed does not have pubDate)
            if let published = rssItem.dublinCore?.dcDate {
                workingItem.published = published
            }
        }

        if let title = rssItem.title?.preparingTitle() {
            workingItem.title = title
        } else {
            workingItem.title = "Untitled"
        }

        workingItem.link = rssItem.linkURL
    }

    private func populateSummary() {
        // Extract plain text from summary or content
        if let source = rssItem.description?.htmlUnescape() {
            workingItem.summary = SummaryHTML(source).plainText()
        } else if let source = rssItem.content?.contentEncoded {
            workingItem.summary = SummaryHTML(source).plainText()
        }
    }

    private func findEnclosureImage() {
        if
            let enclosure = rssItem.enclosure,
            let urlString = enclosure.attributes?.url,
            let url = URL(string: urlString, relativeTo: workingItem.link),
            let mimeType = enclosure.attributes?.type,
            ImageMIMEType(rawValue: mimeType) != nil
        {
            self.workingItem.imagePool.append(RankedImage(url: url.absoluteURL))
        }
    }

    private func findMediaContentImages() {
        // Extract images from <media:content>
        if let mediaContents = rssItem.media?.mediaContents {
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
                        workingItem.imagePool.append(RankedImage(
                            url: url.absoluteURL,
                            rank: width * height,
                            width: width,
                            height: height
                        ))
                    } else {
                        workingItem.imagePool.append(RankedImage(
                            url: url.absoluteURL,
                            rank: Int(ImageSize.thumbnail.area) + 2)
                        )
                    }
                }
            }
        }
    }

    private func findMediaGroupImages() {
        if let mediaGroupContents = rssItem.media?.mediaGroup?.mediaContents {
            for media in mediaGroupContents {
                if
                    let urlString = media.attributes?.url,
                    let url = URL(string: urlString, relativeTo: workingItem.link),
                    mediaIsImage(mimeType: media.attributes?.type, medium: media.attributes?.medium)
                {
                    if
                        let width = media.attributes?.width,
                        let height = media.attributes?.height
                    {
                        workingItem.imagePool.append(RankedImage(
                            url: url.absoluteURL,
                            rank: width * height,
                            width: width,
                            height: height
                        ))
                    } else {
                        workingItem.imagePool.append(RankedImage(url: url.absoluteURL))
                    }
                }
            }
        }
    }

    private func findMediaThumbnailsImages() {
        if let thumbnails = rssItem.media?.mediaThumbnails {
            for thumbnail in thumbnails {
                if
                    let urlString = thumbnail.attributes?.url,
                    let url = URL(string: urlString, relativeTo: workingItem.link)
                {
                    if
                        let width = Int(thumbnail.attributes?.width ?? ""),
                        let height = Int(thumbnail.attributes?.height ?? "")
                    {
                        workingItem.imagePool.append(RankedImage(
                            url: url.absoluteURL,
                            rank: width * height,
                            width: width,
                            height: height
                        ))
                    } else {
                        workingItem.imagePool.append(RankedImage(url: url.absoluteURL))
                    }
                }
            }
        }
    }

    private func findContentImages() {
        if let source = rssItem.content?.contentEncoded {
            if let allowedImages = SummaryHTML(source).allowedImages(itemLink: workingItem.link) {
                workingItem.imagePool.append(contentsOf: allowedImages)
            }
        }
    }

    private func findDescriptionImages() {
        if let source = rssItem.description?.htmlUnescape() {
            if let allowedImages = SummaryHTML(source).allowedImages(itemLink: workingItem.link) {
                workingItem.imagePool.append(contentsOf: allowedImages)
            }
        }
    }
}
