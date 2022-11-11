//
//  RSSItemLoad.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

import FeedKit

struct RSSItemLoad {
    let item: Item
    let source: RSSFeedItem
    let imageSelection = ImageSelection()
    
    func apply() {
        populateGeneralProperties()
        populateText()
        findEnclosureImage()
        findMediaContentImages()
        findMediaGroupImages()
        findMediaThumbnailsImages()
        findContentImages()
        findDescriptionImages()

        imageSelection.selectImage()
        item.image = imageSelection.image
        item.imageWidth = imageSelection.imageWidth ?? 0
        item.imageHeight = imageSelection.imageHeight ?? 0
    }

    private func populateGeneralProperties() {
        // Prefer RSS pubDate element for published date
        if let published = source.pubDate {
            item.published = published
        } else if let published = source.dublinCore?.dcDate {
            // Fallback to Dublin Core metadata for published date
            // (ex. http://feeds.feedburner.com/oatmealfeed does not have pubDate)
            item.published = published
        }

        if let title = source.title?.preparingTitle() {
            item.title = title
        } else {
            item.title = "Untitled"
        }

        item.link = source.linkURL
        
        if let author = source.dublinCore?.dcCreator {
            let formattedAuthor = author
                .replacingOccurrences(of: "\n", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if formattedAuthor != "" {
                item.author = formattedAuthor
            }
        }
    }

    private func populateText() {
        // Extract plain text from summary or content
        if let description = source.description?.htmlUnescape() {
            item.summary = HTMLContent(description).sanitizedHTML()
        } else if let contentEncoded = source.content?.contentEncoded {
            item.summary = HTMLContent(contentEncoded).sanitizedHTML()
        }

        if let teaser = item.summary {
            item.teaser = HTMLContent(teaser).plainText()?.truncated(limit: 1000)
        }

        if let source = source.content?.contentEncoded {
            item.body = HTMLContent(source).sanitizedHTML()
        }
    }

    private func findEnclosureImage() {
        if
            let enclosure = source.enclosure,
            let urlString = enclosure.attributes?.url,
            let url = URL(string: urlString, relativeTo: item.link),
            let mimeType = enclosure.attributes?.type,
            ImageMIMEType(rawValue: mimeType) != nil
        {
            imageSelection.imagePool.append(RankedImage(url: url.absoluteURL))
        }
    }

    private func findMediaContentImages() {
        // Extract images from <media:content>
        if let mediaContents = source.media?.mediaContents {
            for media in mediaContents {
                if
                    let urlString = media.attributes?.url,
                    let url = URL(string: urlString, relativeTo: item.link),
                    MediaUtil.mediaIsImage(mimeType: media.attributes?.type, medium: media.attributes?.medium)
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
                            url: url.absoluteURL,
                            rank: Int(ImageSize.preview.area))
                        )
                    }
                }
            }
        }
    }

    private func findMediaGroupImages() {
        if let mediaGroupContents = source.media?.mediaGroup?.mediaContents {
            for media in mediaGroupContents {
                if
                    let urlString = media.attributes?.url,
                    let url = URL(string: urlString, relativeTo: item.link),
                    MediaUtil.mediaIsImage(mimeType: media.attributes?.type, medium: media.attributes?.medium)
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
                            url: url.absoluteURL,
                            rank: Int(ImageSize.preview.area)
                        ))
                    }
                }
            }
        }
    }

    private func findMediaThumbnailsImages() {
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
                            rank: Int(ImageSize.thumbnail.area)
                        ))
                    }
                }
            }
        }
    }

    private func findContentImages() {
        if let source = source.content?.contentEncoded {
            if let allowedImages = HTMLContent(source).allowedImages(itemLink: item.link) {
                imageSelection.imagePool.append(contentsOf: allowedImages)
            }
        }
    }

    private func findDescriptionImages() {
        if let source = source.description?.htmlUnescape() {
            if let allowedImages = HTMLContent(source).allowedImages(itemLink: item.link) {
                imageSelection.imagePool.append(contentsOf: allowedImages)
            }
        }
    }
    
}
